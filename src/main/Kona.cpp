#include <stdio.h>
#include <malloc.h>

#define CAPACITY 4
#define SUBPAGE 0xfff
#define INDEX 86

unsigned long long access = 0;
unsigned long long write_back = 0;

typedef struct addr {
	unsigned head;
	unsigned tail;
	addr* next;
}*Addr;
typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
	Addr first;
	int dirty;
}*Page;
typedef struct fifoList {
	Page list_head;
	Page list_tail;
	unsigned list_size;
}*FIFOList, ** Cache;

void insert(Page p, unsigned offset, unsigned size)
{
	Addr tmp = p->first, left = p->first;

	if (offset + size < tmp->head) {
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = p->first;
		p->first = ad;
		return;
	}

	while (tmp != NULL) {
		if (tmp->tail + 1 >= offset) break;
		left = tmp;
		tmp = tmp->next;
	}

	if (tmp == NULL) {
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = NULL;
		left->next = ad;
		return;
	}
	else if (offset + size < tmp->head) {
		Addr ad = (Addr)malloc(sizeof(addr));
		ad->head = offset;
		ad->tail = offset + size - 1;
		ad->next = tmp;
		left->next = ad;
		return;
	}
	else {
		tmp->head = tmp->head < offset ? tmp->head : offset;
		tmp->tail = tmp->tail > (offset + size - 1) ? tmp->tail : (offset + size - 1);
		while (tmp->next && tmp->tail >= tmp->next->head) {
			tmp->tail = tmp->tail > tmp->next->tail ? tmp->tail : tmp->next->tail;
			Addr t = tmp->next;
			tmp->next = tmp->next->next;
			free(t);
		}
	}
}

void PrintSize(Page p, FILE* fp)
{
	unsigned size = 0;
	Addr ad = p->first;
	while (ad) {
		size += ad->tail - ad->head + 1;
		//		printf("ad->head=%x ad->tail=%x size=%u \n", ad->head, ad->tail, size);
		Addr tmp = ad;
		ad = ad->next;
		free(tmp);
	}
	fprintf(fp, "%llx %u\n", p->page_num, size);
	if(p->dirty){
		write_back++;
	}
}

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

void listDelete(FIFOList fifo, FILE* fp)
{
	Page tmp_pg = fifo->list_tail;
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

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

void createPage(FIFOList fifo, unsigned long long tmp_page_num, unsigned offset, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;

	if (fifo->list_size == 0)
	{
		Page pg = (Page)malloc(sizeof(pageNode));
		pg->llink = NULL;
		pg->rlink = NULL;
		pg->page_num = tmp_page_num;
		if(is_write)
			pg->dirty = 1;

		pg->first = (Addr)malloc(sizeof(addr));
		pg->first->head = offset;
		pg->first->tail = offset + tmp_size - 1;
		pg->first->next = NULL;
		fifo->list_head = pg;
		fifo->list_tail = pg;
		fifo->list_size = 1;
		return;
	}
	else {
		Page tmp_pg = NULL;
		if (fifo->list_size > 0) {
			tmp_pg = fifo->list_head;
			for (unsigned i = fifo->list_size; i > 0; i--) {
				if (tmp_pg->page_num == tmp_page_num) {
					flag = 1;
					if(is_write)
					    tmp_pg->dirty = 1;
					break;
				}
				tmp_pg = tmp_pg->rlink;
			}
		}
		if (flag == 0) {
			Page pg = (Page)malloc(sizeof(pageNode));
			pg->llink = NULL;
			pg->rlink = NULL;
			pg->page_num = tmp_page_num;
			if(is_write)
				pg->dirty = 1;

			pg->first = (Addr)malloc(sizeof(addr));
			pg->first->head = offset;
			pg->first->tail = offset + tmp_size - 1;
			pg->first->next = NULL;

			if (fifo->list_size < CAPACITY) {
				listInsert(fifo, pg);
			}
			else {
				listDelete(fifo, fp);
				listInsert(fifo, pg);
			}
		}
		if (flag == 1) {
			insert(tmp_pg, offset, tmp_size);
		}
	}
}

int main(int argc, char* argv[])
{
	FILE* trace;
	trace = fopen(argv[1], "r");
	if (!trace)
		printf("Unable open the file!\n");
	FILE* fp;
	fp = fopen(argv[2], "w");
	if (!fp)
		printf("Unable open the file!\n");

	Cache cache = (Cache)malloc(sizeof(FIFOList) * (INDEX + 1));
	for (int i = 0; i < INDEX + 1; i++) {
		cache[i] = (FIFOList)malloc(sizeof(fifoList));
		cache[i]->list_size = 0;
	}

	double line = 0;
	unsigned long long pre_page = 0;
	char c = ' ';
	int dirty = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_group = 0, tmp_page = 0; 
		unsigned tmp_size = 0, offset = 0; 			 
		dirty = 0;

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}

		if(c == 'W')
			dirty = 1;

		tmp_page = tmp_num / (SUBPAGE + 0x1);
		tmp_group = (tmp_num / (SUBPAGE + 0x1)) % INDEX;
		offset = tmp_num & SUBPAGE;

		++line;

		if (offset + tmp_size - 1 <= SUBPAGE) {
			createPage(cache[tmp_group], tmp_page, offset, tmp_size, fp, dirty);
			if (tmp_page != pre_page) {
				access++;
				pre_page = tmp_page;
			}
		}
		else {
			createPage(cache[tmp_group], tmp_page, offset, SUBPAGE - offset + 1, fp, dirty);
			if (tmp_page != pre_page) {
				access++;
				pre_page = tmp_page;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (SUBPAGE - offset + 1);
			tmp_group = tmp_page % INDEX;
			while (tmp_size > 0) {
				if (tmp_size >= (SUBPAGE + 1)) {
					createPage(cache[tmp_group], tmp_page, 0, SUBPAGE + 1, fp, dirty);
					if (tmp_page != pre_page) {
						access++;
						pre_page = tmp_page;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (SUBPAGE - 0 + 1);
					tmp_group = tmp_page % INDEX;
				}
				else
				{
					createPage(cache[tmp_group], tmp_page, 0, tmp_size, fp, dirty);
					if (tmp_page != pre_page) {
						access++;
						pre_page = tmp_page;
					}
					break;
				}
			}
		}
	}

	for (int i = 0; i < INDEX + 1; i++) {
		while (cache[i]->list_size) {
			listDelete(cache[i], fp);
		}
		free(cache[i]);
	}
	free(cache);

	fprintf(fp, "#page_access: %llu\n", access);
	fprintf(fp, "#write_back: %llu\n", write_back);

	fclose(fp);
	fclose(trace);

	return 0;
}
