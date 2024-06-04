#include <stdio.h>
#include <malloc.h>
#include <map>

#define SUBPAGE 0xfff

typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
}*Page;
typedef struct list {
	Page head;
	Page tail;
	unsigned size;
}*List;

std::map<unsigned long long, Page> list_map;

void listInsert(List list, Page pg)
{
	if (list->size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		list->head = pg;
		list->tail = pg;
		list->size = 1;
		return;
	}
	Page tmp_pg = list->head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->head = pg;
	list->size += 1;
}

void listDeleteTail(List list)
{
	Page tmp_pg = list->tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		list->tail = tmp_pg->llink;
	}
	else {
		list->head = NULL;
		list->tail = NULL;
	}
	list->size -= 1;
	list_map.erase(tmp_pg->page_num);
	free(tmp_pg);
}

int searchList(List list, unsigned long long tmp_page_num)
{
	Page p = NULL;
	if (list->size != 0) {
		auto it = list_map.find(tmp_page_num);
		if (it != list_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 1;
		}
	}
	p = (Page)malloc(sizeof(pageNode));
	p->llink = NULL;
	p->rlink = NULL;
	p->page_num = tmp_page_num;
	list_map.insert({ p->page_num,p });
	listInsert(list, p);

	return 0;
}

int main(int argc, char* argv[])
{
	FILE* trace;
	trace = fopen(argv[1], "r");
	if (!trace)
		printf("Unable open the file!\n");
	FILE* fp;
	fp = fopen(argv[2], "w");
	if (!trace)
		printf("Unable open the file!\n");

	List countlist = (List)malloc(sizeof(list));
	countlist->size = 0;
	double count = 0;
	double line = 0;
	int tmp_line = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_page = 0; 
		unsigned tmp_size = 0; 			 
		char c = ' ';

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}
		if (c != 'W' && c != 'R')
			break;

		tmp_page = tmp_num / (SUBPAGE + 0x1);
		if (searchList(countlist, tmp_page)==0) {
			count++;
		}
		tmp_line++;
		if (tmp_line == 2000000000)
			line += tmp_line;

	}
	fprintf(fp, "#page_size:%dB\n", SUBPAGE + 1);
	fprintf(fp, "#page_num:%.0lf\n", count);
	fprintf(fp, "#memory_size:%lfKB\n", (SUBPAGE + 1) * count / 1024);

	while (countlist->size) {
		listDeleteTail(countlist);
	}
	free(countlist);

	fclose(fp);
	fclose(trace);

	return 0;
}


