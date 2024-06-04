#include <stdio.h>
#include <malloc.h>

#define CACHELINE 0x3f
#define L1_SET 64
#define L1_WAY 12
#define L2_SET 1024
#define L2_WAY 20
#define L3_SET 32768
#define L3_WAY 12

typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
}*Page;
typedef struct fifoList {
	Page list_head;
	Page list_tail;
	unsigned list_size;
}*FIFOList;
typedef struct l3_cache {
	FIFOList* L1_cache;
	FIFOList* L2_cache;
	FIFOList* L3_cache;
}*L3_Cache;

void listInsert(FIFOList fifo, Page pg)
{
	if (fifo->list_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		fifo->list_head = pg;
		fifo->list_tail = pg;
		fifo->list_size = 1;
		return;
	}
	Page tmp_pg = fifo->list_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	fifo->list_head = pg;
	fifo->list_size += 1;
}

unsigned long long listDeleteTail(FIFOList fifo)
{
	Page tmp_pg = fifo->list_tail;
	unsigned long long tmp_page_num = tmp_pg->page_num;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		fifo->list_tail = tmp_pg->llink;
	}
	else {
		fifo->list_head = NULL;
		fifo->list_tail = NULL;
	}
	fifo->list_size -= 1;
	free(tmp_pg);
	return tmp_page_num;
}

void L1DeletePage(FIFOList* L1_cache, unsigned long long tmp_page_num)
{
	int L1_group = tmp_page_num % L1_SET;
	if (L1_cache[L1_group]->list_size > 0) {
		Page tmp_pg = L1_cache[L1_group]->list_head;
		for (unsigned i = L1_cache[L1_group]->list_size; i > 0; i--) {
			if (tmp_pg->page_num == tmp_page_num) {
				if (tmp_pg->llink == NULL) {
					if (tmp_pg->rlink == NULL) {
						L1_cache[L1_group]->list_head = NULL;
						L1_cache[L1_group]->list_tail = NULL;
						L1_cache[L1_group]->list_size -= 1;
					}
					else {
						L1_cache[L1_group]->list_head = tmp_pg->rlink;
						tmp_pg->rlink->llink = tmp_pg->llink;
						L1_cache[L1_group]->list_size -= 1;
					}
				}
				else {
					if (tmp_pg->rlink == NULL) {
						L1_cache[L1_group]->list_tail = tmp_pg->llink;
						tmp_pg->llink->rlink = tmp_pg->rlink;
						L1_cache[L1_group]->list_size -= 1;
					}
					else {
						tmp_pg->llink->rlink = tmp_pg->rlink;
						tmp_pg->rlink->llink = tmp_pg->llink;
						L1_cache[L1_group]->list_size -= 1;
					}
				}
				break;
			}
			tmp_pg = tmp_pg->rlink;
		}
	}
}

void L2DeletePage(FIFOList* L2_cache, unsigned long long tmp_page_num)
{
	int L2_group = tmp_page_num % L2_SET;
	if (L2_cache[L2_group]->list_size > 0) {
		Page tmp_pg = L2_cache[L2_group]->list_head;
		for (unsigned i = L2_cache[L2_group]->list_size; i > 0; i--) {
			if (tmp_pg->page_num == tmp_page_num) {
				if (tmp_pg->llink == NULL) {
					if (tmp_pg->rlink == NULL) {
						L2_cache[L2_group]->list_head = NULL;
						L2_cache[L2_group]->list_tail = NULL;
						L2_cache[L2_group]->list_size -= 1;
					}
					else {
						L2_cache[L2_group]->list_head = tmp_pg->rlink;
						tmp_pg->rlink->llink = tmp_pg->llink;
						L2_cache[L2_group]->list_size -= 1;
					}
				}
				else {
					if (tmp_pg->rlink == NULL) {
						L2_cache[L2_group]->list_tail = tmp_pg->llink;
						tmp_pg->llink->rlink = tmp_pg->rlink;
						L2_cache[L2_group]->list_size -= 1;
					}
					else {
						tmp_pg->llink->rlink = tmp_pg->rlink;
						tmp_pg->rlink->llink = tmp_pg->llink;
						L2_cache[L2_group]->list_size -= 1;
					}
				}
				break;
			}
			tmp_pg = tmp_pg->rlink;
		}
	}
}


int readCache(L3_Cache cache, unsigned long long tmp_page_num)
{
	int flag = 0;
	int L1_group = tmp_page_num % L1_SET;
	int L2_group = tmp_page_num % L2_SET;
	int L3_group = tmp_page_num % L3_SET;

	Page tmp_pg = NULL;
	if (cache->L1_cache[L1_group]->list_size > 0) {
		tmp_pg = cache->L1_cache[L1_group]->list_head;
		for (unsigned i = cache->L1_cache[L1_group]->list_size; i > 0; i--) {
			if (tmp_pg->page_num == tmp_page_num) {
				flag = 1;
				break;
			}
			tmp_pg = tmp_pg->rlink;
		}
	}
	else if (flag == 0 && cache->L2_cache[L2_group]->list_size > 0)
	{
		tmp_pg = cache->L2_cache[L2_group]->list_head;
		for (unsigned i = cache->L2_cache[L2_group]->list_size; i > 0; i--) {
			if (tmp_pg->page_num == tmp_page_num) {
				flag = 2;
				break;
			}
			tmp_pg = tmp_pg->rlink;
		}
	}
	else if (flag == 0 && cache->L3_cache[L3_group]->list_size > 0)
	{
		tmp_pg = cache->L3_cache[L3_group]->list_head;
		for (unsigned i = cache->L3_cache[L3_group]->list_size; i > 0; i--) {
			if (tmp_pg->page_num == tmp_page_num) {
				flag = 3;
				break;
			}
			tmp_pg = tmp_pg->rlink;
		}
	}

	if (flag == 0) {
		Page pg3 = (Page)malloc(sizeof(pageNode));
		pg3->llink = NULL;
		pg3->rlink = NULL;
		pg3->page_num = tmp_page_num;
		if (cache->L3_cache[L3_group]->list_size < L3_WAY) {
			listInsert(cache->L3_cache[L3_group], pg3);
		}
		else {
			unsigned long long tmp_num = listDeleteTail(cache->L3_cache[L3_group]);
			L2DeletePage(cache->L2_cache, tmp_num);
			L1DeletePage(cache->L1_cache, tmp_num);
			listInsert(cache->L3_cache[L3_group], pg3);
		}

		Page pg2 = (Page)malloc(sizeof(pageNode));
		pg2->llink = NULL;
		pg2->rlink = NULL;
		pg2->page_num = tmp_page_num;
		if (cache->L2_cache[L2_group]->list_size < L2_WAY) {
			listInsert(cache->L2_cache[L2_group], pg2);
		}
		else {
			unsigned long long tmp_num = listDeleteTail(cache->L2_cache[L2_group]);
			L1DeletePage(cache->L1_cache, tmp_num);
			listInsert(cache->L2_cache[L2_group], pg2);
		}

		Page pg1 = (Page)malloc(sizeof(pageNode));
		pg1->llink = NULL;
		pg1->rlink = NULL;
		pg1->page_num = tmp_page_num;
		if (cache->L1_cache[L1_group]->list_size < L1_WAY) {
			listInsert(cache->L1_cache[L1_group], pg1);
		}
		else {
			listDeleteTail(cache->L1_cache[L1_group]);
			listInsert(cache->L1_cache[L1_group], pg1);
		}
	}
	if (flag == 1) {

	}
	if (flag == 2) {
		Page pg1 = (Page)malloc(sizeof(pageNode));
		pg1->llink = NULL;
		pg1->rlink = NULL;
		pg1->page_num = tmp_page_num;
		if (cache->L1_cache[L1_group]->list_size < L1_WAY) {
			listInsert(cache->L1_cache[L1_group], pg1);
		}
		else {
			listDeleteTail(cache->L1_cache[L1_group]);
			listInsert(cache->L1_cache[L1_group], pg1);
		}
	}
	if (flag == 3) {
		Page pg2 = (Page)malloc(sizeof(pageNode));
		pg2->llink = NULL;
		pg2->rlink = NULL;
		pg2->page_num = tmp_page_num;
		if (cache->L2_cache[L2_group]->list_size < L2_WAY) {
			listInsert(cache->L2_cache[L2_group], pg2);
		}
		else {
			unsigned long long tmp_num = listDeleteTail(cache->L2_cache[L2_group]);
			L1DeletePage(cache->L1_cache, tmp_num);
			listInsert(cache->L2_cache[L2_group], pg2);
		}

		Page pg1 = (Page)malloc(sizeof(pageNode));
		pg1->llink = NULL;
		pg1->rlink = NULL;
		pg1->page_num = tmp_page_num;
		if (cache->L1_cache[L1_group]->list_size < L1_WAY) {
			listInsert(cache->L1_cache[L1_group], pg1);
		}
		else {
			listDeleteTail(cache->L1_cache[L1_group]);
			listInsert(cache->L1_cache[L1_group], pg1);
		}
	}

	return flag;
}

int main(int argc, char* argv[])
{
	FILE* trace;
	trace = fopen(argv[1], "r");
	if (!trace)
		printf("Unable open trace file!\n");
	FILE* fp;
	fp = fopen(argv[2], "w");
	if (!fp)
		printf("Unable open fp file!\n");

	L3_Cache cache = (L3_Cache)malloc(sizeof(l3_cache));
	cache->L1_cache = (FIFOList*)malloc(sizeof(FIFOList) * L1_SET);
	for (int i = 0; i < L1_SET; i++) {
		cache->L1_cache[i] = (FIFOList)malloc(sizeof(fifoList));
		cache->L1_cache[i]->list_size = 0;
	}
	cache->L2_cache = (FIFOList*)malloc(sizeof(FIFOList) * L2_SET);
	for (int i = 0; i < L2_SET; i++) {
		cache->L2_cache[i] = (FIFOList)malloc(sizeof(fifoList));
		cache->L2_cache[i]->list_size = 0;
	}
	cache->L3_cache = (FIFOList*)malloc(sizeof(FIFOList) * L3_SET);
	for (int i = 0; i < L3_SET; i++) {
		cache->L3_cache[i] = (FIFOList)malloc(sizeof(fifoList));
		cache->L3_cache[i]->list_size = 0;
	}

	double line = 0;
	unsigned long long pre_page = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_page = 0; 
		unsigned tmp_size = 0, offset = 0; 			 
		char c = ' ';

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}

		++line;

		if (tmp_num == pre_page)
			continue;

		tmp_page = tmp_num / (CACHELINE + 0x1);
		offset = tmp_num & CACHELINE;

		if (offset + tmp_size - 1 <= CACHELINE) {
			if (readCache(cache, tmp_page) == 0) {
				fprintf(fp, "%c 0x%llx %u\n", c, tmp_num - offset, 64);
			}
			if (tmp_page != pre_page) {
				pre_page = tmp_page;
			}
		}
		else {
			if (readCache(cache, tmp_page) == 0) {
				fprintf(fp, "%c 0x%llx %u\n", c, tmp_num - offset, 64);
			}
			if (tmp_page != pre_page) {
				pre_page = tmp_page;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (CACHELINE - offset + 1);
			while (tmp_size > 0) {
				if (tmp_size >= (CACHELINE + 1)) {
					if (readCache(cache, tmp_page) == 0) {
						fprintf(fp, "%c 0x%llx %u\n", c, tmp_num - offset, 64);
					}
					if (tmp_page != pre_page) {
						pre_page = tmp_page;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (CACHELINE - 0 + 1);
				}
				else
				{
					if (readCache(cache, tmp_page) == 0) {
						fprintf(fp, "%c 0x%llx %u\n", c, tmp_num - offset, 64);
					}
					if (tmp_page != pre_page) {
						pre_page = tmp_page;
					}
					break;
				}
			}
		}
	}

	for (int i = 0; i < L1_SET; i++) {
		while (cache->L1_cache[i]->list_size) {
			listDeleteTail(cache->L1_cache[i]);
		}
		free(cache->L1_cache[i]);
	}
	free(cache->L1_cache);
	for (int i = 0; i < L2_SET; i++) {
		while (cache->L2_cache[i]->list_size) {
			listDeleteTail(cache->L2_cache[i]);
		}
		free(cache->L2_cache[i]);
	}
	free(cache->L2_cache);
	for (int i = 0; i < L3_SET; i++) {
		while (cache->L3_cache[i]->list_size) {
			listDeleteTail(cache->L3_cache[i]);
		}
		free(cache->L3_cache[i]);
	}
	free(cache->L3_cache);
	free(cache);

	fclose(fp);
	fclose(trace);

	return 0;
}
