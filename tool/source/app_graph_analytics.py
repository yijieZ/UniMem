#!/usr/bin/python3

import os
import sys
import getopt
import random
import subprocess
import time
os.environ["OMP_NUM_THREADS"] = "10"
import turicreate


def usage():
  print (sys.argv[0] + " --graph <graph> --app <app> [--threads <threads>] [--verbose] [--pbsim]")
  print (sys.argv[0] + " -g <graph> -a <app> [-t <threads>] [-v] [-s]")
  print ("graph: wiki/twitter (default: wiki)")
  print ("app: pagerank/connectedcomp/graphcol/labelprop (default: pagerank)")
  print ("pbsim: simulation mode (default: no simulation)")

################### PBSIM ###############################
def do_attach_pbsim():
  #attach PBSim
  if config_attach_pbsim:
    subprocess.Popen(tracker + " -p " + str(pid), shell=True)
    time.sleep(SLEEPTIME)

################## LOAD GRAPH ##########################

def do_load_graph_wiki():
  print ("[K] Loading Wiki graph")
  if os.path.exists(data_w_path):
    print ("[K] Loading graph from local path")
    sg = turicreate.load_sgraph(data_w_path)
  else:
    sg = turicreate.load_sgraph(url)
    sg.save(data_w_path)

  print (sg.summary())
  sys.stdout.flush()

  time.sleep(5)
  return sg


def do_load_graph_twitter():
  # Load data
  print ("[K]: Loading Twitter graph")
  if os.path.exists(data_w_path_edges):
    print ("[K]: Loading graph from local path")
    edges = turicreate.SFrame.read_csv(data_w_path_edges, header=False)
    edges = edges.rename({'X1':'src_node', 'X2':'dst_node'})
    print (edges)
  else:
    print ("[K][ERROR]: Can't find data! " + data_w_path_edges)
    exit(1)

  if os.path.exists(data_w_path_nodes):
    print ("[K]: Loading graph from local path")
    nodes = turicreate.SFrame.read_csv(data_w_path_nodes, header=False)
    nodes = nodes.rename({'X1':'node_id'})
    print (nodes)
  else:
    print ("[K][ERROR]: Can't find nodes data! " + data_w_path_nodes)
    exit(1)

  # Create graph 
  sg = turicreate.SGraph()
  sg = sg.add_vertices(nodes, vid_field='node_id')
  sg = sg.add_edges(edges, src_field='src_node', dst_field='dst_node')
  print (sg.summary())
  sys.stdout.flush()

  time.sleep(10)
  return sg


def do_load_graph(graph):
  if graph == "twitter":
    return do_load_graph_twitter()
  else:
    return do_load_graph_wiki()

################# PAGE RANK #############################
def run_page_rank(sg):
  print ("[K]: Running PageRank")
  sys.stdout.flush()
  
  do_attach_pbsim()

  pr = turicreate.pagerank.create(sg, max_iterations=10, verbose=True)
  print ("[K]: Done Running PageRank")
  sys.stdout.flush()

  print (pr.summary())



################# CONNECTED COMPONENTS #############################
def run_connected_comp(sg):
  print ("[K]: Running ConnectedComponents")
  sys.stdout.flush()

  do_attach_pbsim()

  cc = turicreate.connected_components.create(sg)

  print ("[K]: Done Running ConnectedComponents")
  sys.stdout.flush()

  print (cc.summary())



################# GRAPH COLORING  #############################
def run_graph_coloring(sg):
  print ("[K]: Running GraphColoring")
  sys.stdout.flush()

  do_attach_pbsim()

  color = turicreate.graph_coloring.create(sg)
  print ("[K]: Done Running GraphColoring")

  color_id = color['color_id']
  num_colors = color['num_colors']
  sys.stdout.flush()

  print ("color_id")
  print (color_id)
  print ("num_colors")
  print (num_colors)
  print (color.summary())


################# LABEL PROPAGATION  #############################

def init_label(vid):
  x = random.random()
  if x > 0.9:
    return 0
  elif x < 0.1:
    return 1
  else:
    return None

def run_label_propagation(sg):
  print ("[K]: Running LabelPropagation")
  sys.stdout.flush()

  sg.vertices['labels'] = sg.vertices['__id'].apply(init_label, int)

  do_attach_pbsim()

  m = turicreate.label_propagation.create(sg, label_field='labels')
  labels = m['labels']

  print ("[K]: Done Running LabelPropagation")
  sys.stdout.flush()

  print ("Labels:")
  print (labels)
  print (m.summary())


###################################################################

def do_run_app(app, sg):
  if app == "connectedcomp":
    run_connected_comp(sg)
  elif app == "graphcol":
    run_graph_coloring(sg)
  elif app == "labelprop":
    run_label_propagation(sg)
  else:
    run_page_rank(sg)


######################
config_attach_pbsim = False

tracker='sudo ./tracker'

home=os.path.dirname(os.path.abspath(__file__)) + '/Wiki-dataset/data/'
data_file = 'US_business_links'
data_w_path=home + data_file

home_twitter=os.path.dirname(os.path.abspath(__file__)) + '/Twitter-dataset/data/'
data_file_edges = 'edges.csv'
data_file_nodes = 'nodes.csv'
data_w_path_edges=home_twitter + data_file_edges
data_w_path_nodes=home_twitter + data_file_nodes


SLEEPTIME=5
######################

try:
  opts, args = getopt.getopt(sys.argv[1:], "hsg:a:t:v", ["help", "graph=", "app=", "threads="])
except getopt.GetoptError as err:
  # print help information and exit:
  print(err) # will print something like "option -a not recognized"
  usage()
  sys.exit(2)
graph='wiki'
app='pagerank'
verbose = False
threads = 10
for o, a in opts:
  if o in ("-v", "--verbose"):
    verbose = True
  elif o in ("-s", "--pbsim"):
    config_attach_pbsim = True
  elif o in ("-h", "--help"):
    usage()
    sys.exit()
  elif o in ("-g", "--graph"):
    graph = a
  elif o in ("-a", "--app"):
    app = a
  elif o in ("-t", "--threads"):
    threads = int(a)
  else:
    assert False, "unhandled option"


turicreate.config.set_runtime_config('TURI_DEFAULT_NUM_PYLAMBDA_WORKERS', threads)
pid=os.getpid()

print ("[K]: My pid is " + str(pid))
print ("[K]: Running " + str(threads) + " threads")


sg = do_load_graph(graph)

pid=str(os.getpid())
p = subprocess.Popen('../../pintool/pin -pid #PID -t ../../pintool/source/tools/ManualExamples/obj-intel64/pinatrace.so '.replace('#PID', pid), shell = True)

do_run_app(app, sg)

