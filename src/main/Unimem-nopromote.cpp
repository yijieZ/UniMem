#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <map>
#include <bitset>
#include <iostream>

#define CAPACITY 103
#define ACTIVE (CAPACITY * 9 / 10)
#define INACTIVE ((CAPACITY + 9) / 10)
#define CANDIDATE (CAPACITY * 9 / 10)
#define SUBPAGE 0x1ff
#define INDEX 0x0

using namespace std;

unsigned long long active_hit = 0, inactive_hit = 0, candidate_hit = 0;
unsigned long long access = 0;
unsigned long long page_fault = 0;
unsigned long long write_back = 0;

typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
	bitset<SUBPAGE + 1> addr;
	int dirty;
}*Page;
typedef struct lruList {
	Page active_head;
	Page active_tail;
	Page inactive_head;
	Page inactive_tail;
	Page candidate_head;
	Page candidate_tail;
	unsigned active_size;
	unsigned inactive_size;
	unsigned candidate_size;
}*LRUList, ** Cache;

std::map<unsigned long long, Page> active_map;
std::map<unsigned long long, Page> inactive_map;
std::map<unsigned long long, Page> candidate_map;

void insert(Page p, unsigned offset, unsigned size)
{
	for (int i = 0; i < size; i++)
	{
		p->addr.set(offset + i);
	}

}

void PrintSize(Page p, FILE* fp)
{
	unsigned size = 0;
	for (int i = 0; i < SUBPAGE + 1; i++) {
		size += p->addr[i];
	}

	fprintf(fp, "%llx %u\n", p->page_num, size);
	if(p->dirty)
		write_back++;
}

void activeInsert(LRUList lru, Page pg)
{
	if (lru->active_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		lru->active_head = pg;
		lru->active_tail = pg;
		lru->active_size = 1;
		return;
	}
	Page tmp_pg = lru->active_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	lru->active_head = pg;
	lru->active_size += 1;
}

void activeDeleteTail(LRUList lru, FILE* fp)
{
	Page tmp_pg = lru->active_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		lru->active_tail = tmp_pg->llink;
	}
	else {
		lru->active_head = NULL;
		lru->active_tail = NULL;
	}
	lru->active_size -= 1;

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

void candidateInsert(LRUList lru, Page pg)
{
	if (lru->candidate_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		lru->candidate_head = pg;
		lru->candidate_tail = pg;
		lru->candidate_size = 1;
		return;
	}
	Page tmp_pg = lru->candidate_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	lru->candidate_head = pg;
	lru->candidate_size += 1;
}

void candidateDeleteTail(LRUList lru)
{
	Page tmp_pg = lru->candidate_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		lru->candidate_tail = tmp_pg->llink;
	}
	else {
		lru->candidate_head = NULL;
		lru->candidate_tail = NULL;
	}
	lru->candidate_size -= 1;

	free(tmp_pg);
}

void inactiveInsert(LRUList lru, Page pg)
{
	if (lru->inactive_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		lru->inactive_head = pg;
		lru->inactive_tail = pg;
		lru->inactive_size = 1;
		return;
	}
	Page tmp_pg = lru->inactive_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	lru->inactive_head = pg;
	lru->inactive_size += 1;
}

void inactiveDeleteTail(LRUList lru, FILE* fp)
{
	Page tmp_pg = lru->inactive_tail;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		lru->inactive_tail = tmp_pg->llink;
	}
	else {
		lru->inactive_tail = NULL;
		lru->inactive_head = NULL;
	}
	lru->inactive_size -= 1;

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

void inactiveDeleteHead(LRUList lru, FILE* fp)
{
	Page tmp_pg = lru->inactive_head;
	if (tmp_pg->rlink)
	{
		tmp_pg->rlink->llink = NULL;
		lru->inactive_head = tmp_pg->rlink;
	}
	else {
		lru->inactive_tail = NULL;
		lru->inactive_head = NULL;
	}
	lru->inactive_size -= 1;

	PrintSize(tmp_pg, fp);
	free(tmp_pg);
}

int searchList(LRUList lru, unsigned long long tmp_page_num, Page& p)
{
	if (lru->active_size != 0) {
		auto it = active_map.find(tmp_page_num);
		if (it != active_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 2;
		}
	}
	if (lru->inactive_size != 0) {
		auto it = inactive_map.find(tmp_page_num);
		if (it != inactive_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 1;
		}
	}
	if (lru->candidate_size != 0) {
		auto it = candidate_map.find(tmp_page_num);
		if (it != candidate_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 3;
		}
	}
	return 0;
}

int createPage(LRUList lru, unsigned long long tmp_page_num, unsigned offset, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;

	Page tmp_pg = NULL;
	flag = searchList(lru, tmp_page_num, tmp_pg);
	if (flag == 0) {
		Page pg = (Page)malloc(sizeof(pageNode));
		pg->llink = NULL;
		pg->rlink = NULL;
		pg->page_num = tmp_page_num;
		pg->addr = 0;
		if(is_write)
			pg->dirty = 1;

		insert(pg, offset, tmp_size);
		if (lru->inactive_size < INACTIVE) {
			inactive_map.insert({ pg->page_num, pg });
			inactiveInsert(lru, pg);
		}
		else {
			unsigned long long candidate_num = 0;
			candidate_num = lru->inactive_tail->page_num;
			inactive_map.erase(candidate_num);
			inactiveDeleteTail(lru, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (lru->candidate_size < CANDIDATE) {
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			else {
				candidate_map.erase(lru->candidate_tail->page_num);
				candidateDeleteTail(lru);
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			inactive_map.insert({ pg->page_num, pg });
			inactiveInsert(lru, pg);
		}
	}
	if (flag == 1) {
		if(is_write)
			tmp_pg->dirty = 1;

		insert(tmp_pg, offset, tmp_size);
		inactive_map.erase(tmp_pg->page_num);
		if (tmp_pg->llink == NULL) {
			if (tmp_pg->rlink == NULL) {
				lru->inactive_head = NULL;
				lru->inactive_tail = NULL;
				lru->inactive_size -= 1;
			}
			else {
				lru->inactive_head = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				lru->inactive_size -= 1;
			}
		}
		else {
			if (tmp_pg->rlink == NULL) {
				lru->inactive_tail = tmp_pg->llink;
				tmp_pg->llink->rlink = tmp_pg->rlink;
				lru->inactive_size -= 1;
			}
			else {
				tmp_pg->llink->rlink = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				lru->inactive_size -= 1;
			}
		}
		if (lru->active_size < ACTIVE) {
			active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeInsert(lru, tmp_pg);
		}
		else {
			unsigned long long candidate_num = 0;
			candidate_num = lru->active_tail->page_num;
			active_map.erase(candidate_num);
			activeDeleteTail(lru, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (lru->candidate_size < CANDIDATE) {
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			else {
				candidate_map.erase(lru->candidate_tail->page_num);
				candidateDeleteTail(lru);
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeInsert(lru, tmp_pg);
		}
	}
	if (flag == 2) {
		if(is_write)
			tmp_pg->dirty = 1;

		insert(tmp_pg, offset, tmp_size);
		if (tmp_pg->llink == NULL) {
			;
		}
		else if (tmp_pg->rlink == NULL) {
			lru->active_tail = tmp_pg->llink;
			tmp_pg->llink->rlink = NULL;
			lru->active_size -= 1;
			activeInsert(lru, tmp_pg);
		}
		else {
			tmp_pg->llink->rlink = tmp_pg->rlink;
			tmp_pg->rlink->llink = tmp_pg->llink;
			lru->active_size -= 1;
			activeInsert(lru, tmp_pg);
		}
	}
	if (flag == 3) {
		if(is_write)
			tmp_pg->dirty = 1;

		insert(tmp_pg, offset, tmp_size);

		candidate_map.erase(tmp_pg->page_num);
		if (tmp_pg->llink == NULL) {
			if (tmp_pg->rlink == NULL) {
				lru->candidate_head = NULL;
				lru->candidate_tail = NULL;
				lru->candidate_size -= 1;
			}
			else {
				lru->candidate_head = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				lru->candidate_size -= 1;
			}
		}
		else {
			if (tmp_pg->rlink == NULL) {
				lru->candidate_tail = tmp_pg->llink;
				tmp_pg->llink->rlink = tmp_pg->rlink;
				lru->candidate_size -= 1;
			} 
			else {
				tmp_pg->llink->rlink = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				lru->candidate_size -= 1;
			}
		}
		if (lru->active_size < ACTIVE) {
			active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeInsert(lru, tmp_pg);
		}
		else {
			unsigned long long candidate_num = 0;
			candidate_num = lru->active_tail->page_num;
			active_map.erase(candidate_num);
			activeDeleteTail(lru, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (lru->candidate_size < CANDIDATE) {
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			else {
				candidate_map.erase(lru->candidate_tail->page_num);
				candidateDeleteTail(lru);
				candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(lru, candidate_pg);
			}
			active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeInsert(lru, tmp_pg);
		}
	}

	if (flag == 0 || flag == 3)
		page_fault++;

	return flag;
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

	Cache cache = (Cache)malloc(sizeof(LRUList) * (INDEX + 1));
	for (int i = 0; i < INDEX + 1; i++) {
		cache[i] = (LRUList)malloc(sizeof(lruList));
		cache[i]->active_size = 0;
		cache[i]->inactive_size = 0;
		cache[i]->candidate_size = 0;
	}

	double line = 0;
	int flag = 0;
	char c = ' ';
	int dirty = 0;
	while (1) {
		unsigned long long tmp_num = 0, tmp_group = 0, tmp_page = 0;
		unsigned tmp_size = 0, offset = 0; 			
		dirty = 0;

		if (fscanf(trace, "%c %llx %u\n", &c, &tmp_num, &tmp_size) == EOF) {
			break;
		}

		if(c == 'W'){
			dirty = 1;
		}
		tmp_page = tmp_num / (SUBPAGE + 0x1);
		tmp_group = (tmp_num / (SUBPAGE + 0x1)) & INDEX;
		offset = tmp_num & SUBPAGE;

		++line;

		if (offset + tmp_size - 1 <= SUBPAGE) {
			flag = createPage(cache[tmp_group], tmp_page, offset, tmp_size, fp, dirty);
			access++;
			if (flag == 3) {
				candidate_hit++;
			}
			else if (flag == 2) {
				active_hit++;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
		}
		else {
			flag = createPage(cache[tmp_group], tmp_page, offset, SUBPAGE - offset + 1, fp, dirty);
			access++;
			if (flag == 3) {
				candidate_hit++;
			}
			else if (flag == 2) {
				active_hit++;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (SUBPAGE - offset + 1);
			tmp_group = tmp_page & INDEX;
			while (tmp_size > 0) {
				if (tmp_size >= (SUBPAGE + 1)) {
					flag = createPage(cache[tmp_group], tmp_page, 0, SUBPAGE + 1, fp, dirty);
					access++;
					if (flag == 3) {
						candidate_hit++;
					}
					else if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (SUBPAGE - 0 + 1);
					tmp_group = tmp_page & INDEX;
				}
				else
				{
					flag = createPage(cache[tmp_group], tmp_page, 0, tmp_size, fp, dirty);
					access++;
					if (flag == 3) {
						candidate_hit++;
					}
					else if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					break;
				}
			}
		}
	}

	for (int i = 0; i < INDEX + 1; i++) {
		while (cache[i]->inactive_size) {
			inactiveDeleteTail(cache[i], fp);
		}
		while (cache[i]->active_size) {
			activeDeleteTail(cache[i], fp);
		}
		while (cache[i]->candidate_size) {
			candidateDeleteTail(cache[i]);
		}
		free(cache[i]);
	}
	free(cache);

	fprintf(fp, "#page_access: %llu\n", access);
	fprintf(fp, "#page_fault:  %llu \n", page_fault);
	fprintf(fp, "#active_hit:  %llu \n", active_hit);
	fprintf(fp, "#inactive_hit:  %llu \n", inactive_hit);
	fprintf(fp, "#candidate_hit:  %llu \n", candidate_hit);
	fprintf(fp, "#write_back:  %llu \n", write_back);

	fclose(fp);
	fclose(trace);

	return 0;
}
