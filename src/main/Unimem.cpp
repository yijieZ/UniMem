#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <map>
#include <bitset>

#define CAPACITY 1568
#define BIP_CAPACITY CAPACITY * 8 * 0.7
#define LRU_CAPACITY CAPACITY * 0.3
#define ACTIVE (BIP_CAPACITY * 9 / 10)
#define INACTIVE ((BIP_CAPACITY + 9) / 10)
#define CANDIDATE BIP_CAPACITY 
#define SUBPAGE 0x1ff
#define PAGE 0xfff
#define INDEX 0x0
#define PROMOTE_THRESHOLD 8

using namespace std;

unsigned long long active_hit = 0, inactive_hit = 0, candidate_hit = 0, lru_hit = 0;
unsigned long long promote_num = 0;
unsigned long long page_fault = 0;
double page_used = 0, page_sum = 0;
unsigned long long write_back_512 = 0;
unsigned long long write_back_4k = 0;

typedef struct pageNode {
	unsigned long long page_num;
	pageNode* llink;
	pageNode* rlink;
	bitset<PAGE + 1> addr;
	int dirty;
}*Page;
typedef struct bipList {
	Page active_head;
	Page active_tail;
	Page inactive_head;
	Page inactive_tail;
	Page candidate_head;
	Page candidate_tail;
	unsigned active_size;
	unsigned inactive_size;
	unsigned candidate_size;
}*BIPList, ** Cache;
typedef struct lruList {
	Page active_head;
	Page active_tail;
	Page inactive_head;
	Page inactive_tail;
	unsigned active_size;
	unsigned inactive_size;
}*LRUList;

std::map<unsigned long long, Page> bip_active_map;
std::map<unsigned long long, Page> bip_inactive_map;
std::map<unsigned long long, Page> bip_candidate_map;
std::map<unsigned long long, Page> lru_active_map;
std::map<unsigned long long, Page> lru_inactive_map;

void insert(Page p, unsigned offset, unsigned size)
{
	for (int i = 0; i < size; i++)
	{
		p->addr.set(offset + i);
	}
}

void PrintSize(Page p, FILE* fp, unsigned page_size)
{
	unsigned size = 0;
	for (int i = 0; i < PAGE + 1; i++) {
		size += p->addr[i];
	}
	page_used += size;
	page_sum += page_size;

	fprintf(fp, "%llx %u\n", p->page_num, size);
	if(p->dirty){
		if(page_size == (SUBPAGE + 1))
			write_back_512++;
		else if(page_size == (PAGE + 1))
			write_back_4k++;
	}
		

}

void activeBIPInsert(BIPList list, Page pg)
{
	if (list->active_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		list->active_head = pg;
		list->active_tail = pg;
		list->active_size = 1;
		return;
	}
	Page tmp_pg = list->active_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->active_head = pg;
	list->active_size += 1;
}

void activeBIPDeleteTail(BIPList list, FILE* fp)
{
	Page tmp_pg = list->active_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		list->active_tail = tmp_pg->llink;
	}
	else {
		list->active_head = NULL;
		list->active_tail = NULL;
	}
	list->active_size -= 1;

	PrintSize(tmp_pg, fp, SUBPAGE + 1);
	free(tmp_pg);
}

void candidateInsert(BIPList list, Page pg)
{
	if (list->candidate_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		list->candidate_head = pg;
		list->candidate_tail = pg;
		list->candidate_size = 1;
		return;
	}
	Page tmp_pg = list->candidate_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->candidate_head = pg;
	list->candidate_size += 1;
}

void candidateDeleteTail(BIPList list)
{
	Page tmp_pg = list->candidate_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		list->candidate_tail = tmp_pg->llink;
	}
	else {
		list->candidate_head = NULL;
		list->candidate_tail = NULL;
	}
	list->candidate_size -= 1;

	free(tmp_pg);
}

void inactiveBIPInsert(BIPList list, Page pg)
{
	if (list->inactive_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		list->inactive_head = pg;
		list->inactive_tail = pg;
		list->inactive_size = 1;
		return;
	}
	Page tmp_pg = list->inactive_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->inactive_head = pg;
	list->inactive_size += 1;
}

void inactiveBIPDeleteTail(BIPList list, FILE* fp)
{
	Page tmp_pg = list->inactive_tail;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		list->inactive_tail = tmp_pg->llink;
	}
	else {
		list->inactive_tail = NULL;
		list->inactive_head = NULL;
	}
	list->inactive_size -= 1;

	PrintSize(tmp_pg, fp, SUBPAGE + 1);
	free(tmp_pg);
}

void inactiveBIPDeleteHead(BIPList list, FILE* fp)
{
	Page tmp_pg = list->inactive_head;
	if (tmp_pg->rlink)
	{
		tmp_pg->rlink->llink = NULL;
		list->inactive_head = tmp_pg->rlink;
	}
	else {
		list->inactive_tail = NULL;
		list->inactive_head = NULL;
	}
	list->inactive_size -= 1;

	PrintSize(tmp_pg, fp, SUBPAGE + 1);
	free(tmp_pg);
}

void inactiveLRUInsert(LRUList list, Page pg)
{
	if (list->inactive_size == 0) {
		pg->llink = NULL;
		pg->rlink = NULL;
		list->inactive_head = pg;
		list->inactive_tail = pg;
		list->inactive_size = 1;
		return;
	}
	Page tmp_pg = list->inactive_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->inactive_head = pg;
	list->inactive_size += 1;
}

void inactiveLRUDeleteTail(LRUList list, FILE* fp)
{
	Page tmp_pg = list->inactive_tail;
	if (tmp_pg->llink)
	{
		tmp_pg->llink->rlink = NULL;
		list->inactive_tail = tmp_pg->llink;
	}
	else {
		list->inactive_tail = NULL;
		list->inactive_head = NULL;
	}
	list->inactive_size -= 1;

	PrintSize(tmp_pg, fp, PAGE + 1);
	free(tmp_pg);
}

void activeLRUInsert(LRUList list, Page pg)
{
	if (list->active_size == 0)
	{
		pg->llink = NULL;
		pg->rlink = NULL;
		list->active_head = pg;
		list->active_tail = pg;
		list->active_size = 1;
		return;
	}
	Page tmp_pg = list->active_head;
	pg->llink = NULL;
	pg->rlink = tmp_pg;
	tmp_pg->llink = pg;
	list->active_head = pg;
	list->active_size += 1;
}

void activeLRUDeleteTail(LRUList list, FILE* fp)
{
	Page tmp_pg = list->active_tail;
	if (tmp_pg->llink) {
		tmp_pg->llink->rlink = NULL;
		list->active_tail = tmp_pg->llink;
	}
	else {
		list->active_head = NULL;
		list->active_tail = NULL;
	}
	list->active_size -= 1;

	PrintSize(tmp_pg, fp, PAGE + 1);
	free(tmp_pg);
}

int searchList(BIPList list, unsigned long long tmp_page_num, Page& p)
{
	if (list->active_size != 0) {
		auto it = bip_active_map.find(tmp_page_num);
		if (it != bip_active_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 2;
		}
	}
	if (list->inactive_size != 0) {
		auto it = bip_inactive_map.find(tmp_page_num);
		if (it != bip_inactive_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 1;
		}
	}
	if (list->candidate_size != 0) {
		auto it = bip_candidate_map.find(tmp_page_num);
		if (it != bip_candidate_map.end())
		{
			p = it->second;
			if (tmp_page_num == p->page_num)
				return 3;
		}
	}
	return 0;
}

int findLRU(LRUList lru, unsigned long long tmp_num, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;
	Page tmp_pg = NULL;

	unsigned long long tmp_page_num = tmp_num / (PAGE + 0x1);
	unsigned offset = tmp_num & PAGE;
	if (lru->active_size != 0) {
		auto it = lru_active_map.find(tmp_page_num);
		if (it != lru_active_map.end())
		{
			tmp_pg = it->second;
			if (tmp_page_num == tmp_pg->page_num)
				flag = 2;
		}
	}
	if (lru->inactive_size != 0) {
		auto it = lru_inactive_map.find(tmp_page_num);
		if (it != lru_inactive_map.end())
		{
			tmp_pg = it->second;
			if (tmp_page_num == tmp_pg->page_num)
				flag = 1;
		}
	}
	if (flag == 1) {
		if(is_write)
			tmp_pg->dirty = 1;

		insert(tmp_pg, offset, tmp_size);

		lru_inactive_map.erase(tmp_pg->page_num);
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
		if (lru->active_size < LRU_CAPACITY / 2) {
			lru_active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeLRUInsert(lru, tmp_pg);
		}
		else {
			Page lru_pg = lru->active_tail;
			lru_active_map.erase(lru->active_tail->page_num);
			if (lru_pg->llink) {
				lru_pg->llink->rlink = NULL;
				lru->active_tail = lru_pg->llink;
			}
			else {
				lru->active_head = NULL;
				lru->active_tail = NULL;
			}
			lru->active_size -= 1;
			lru_inactive_map.insert({ lru_pg->page_num, lru_pg });
			inactiveLRUInsert(lru, lru_pg);
			lru_active_map.insert({ tmp_pg->page_num,tmp_pg });
			activeLRUInsert(lru, tmp_pg);
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
			activeLRUInsert(lru, tmp_pg);
		}
		else {
			tmp_pg->llink->rlink = tmp_pg->rlink;
			tmp_pg->rlink->llink = tmp_pg->llink;
			lru->active_size -= 1;
			activeLRUInsert(lru, tmp_pg);
		}
	}

	return flag;
}


int createPage(BIPList list, LRUList lru, unsigned long long tmp_page_num, unsigned offset, unsigned tmp_size, FILE* fp, int is_write)
{
	int flag = 0;

	Page tmp_pg = NULL;
	flag = searchList(list, tmp_page_num, tmp_pg);
	if (flag == 0) {
		Page pg = (Page)malloc(sizeof(pageNode));
		pg->llink = NULL;
		pg->rlink = NULL;
		pg->page_num = tmp_page_num;
		pg->addr = 0;
		if(is_write)
			pg->dirty = 1;

		insert(pg, offset, tmp_size);

		if (list->inactive_size < INACTIVE) {
			bip_inactive_map.insert({ pg->page_num, pg });
			inactiveBIPInsert(list, pg);
		}
		else {
			unsigned long long candidate_num = 0;
			candidate_num = list->inactive_tail->page_num;
			bip_inactive_map.erase(candidate_num);
			inactiveBIPDeleteTail(list, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (list->candidate_size < CANDIDATE) {
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			else {
				bip_candidate_map.erase(list->candidate_tail->page_num);
				candidateDeleteTail(list);
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			bip_inactive_map.insert({ pg->page_num, pg });
			inactiveBIPInsert(list, pg);
		}
	}
	if (flag == 1) {
		if(is_write)
			tmp_pg->dirty = 1;
		
		insert(tmp_pg, offset, tmp_size);
		bip_inactive_map.erase(tmp_pg->page_num);
		if (tmp_pg->llink == NULL) {
			if (tmp_pg->rlink == NULL) {
				list->inactive_head = NULL;
				list->inactive_tail = NULL;
				list->inactive_size -= 1;
			}
			else {
				list->inactive_head = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				list->inactive_size -= 1;
			}
		}
		else {
			if (tmp_pg->rlink == NULL) {
				list->inactive_tail = tmp_pg->llink;
				tmp_pg->llink->rlink = tmp_pg->rlink;
				list->inactive_size -= 1;
			}
			else {
				tmp_pg->llink->rlink = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				list->inactive_size -= 1;
			}
		}
		if (list->active_size < ACTIVE) {
			bip_active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeBIPInsert(list, tmp_pg);
		}
		else {
			unsigned long long candidate_num = 0;
			candidate_num = list->active_tail->page_num;
			bip_active_map.erase(candidate_num);
			activeBIPDeleteTail(list, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (list->candidate_size < CANDIDATE) {
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			else {
				bip_candidate_map.erase(list->candidate_tail->page_num);
				candidateDeleteTail(list);
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			bip_active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeBIPInsert(list, tmp_pg);
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
			list->active_tail = tmp_pg->llink;
			tmp_pg->llink->rlink = NULL;
			list->active_size -= 1;
			activeBIPInsert(list, tmp_pg);
		}
		else {
			tmp_pg->llink->rlink = tmp_pg->rlink;
			tmp_pg->rlink->llink = tmp_pg->llink;
			list->active_size -= 1;
			activeBIPInsert(list, tmp_pg);
		}
	}
	if (flag == 3) {
		if(is_write)
			tmp_pg->dirty = 1;

		insert(tmp_pg, offset, tmp_size);

		bip_candidate_map.erase(tmp_pg->page_num);
		if (tmp_pg->llink == NULL) {
			if (tmp_pg->rlink == NULL) {
				list->candidate_head = NULL;
				list->candidate_tail = NULL;
				list->candidate_size -= 1;
			}
			else {
				list->candidate_head = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				list->candidate_size -= 1;
			}
		}
		else {
			if (tmp_pg->rlink == NULL) {
				list->candidate_tail = tmp_pg->llink;
				tmp_pg->llink->rlink = tmp_pg->rlink;
				list->candidate_size -= 1;
			}
			else {
				tmp_pg->llink->rlink = tmp_pg->rlink;
				tmp_pg->rlink->llink = tmp_pg->llink;
				list->candidate_size -= 1;
			}
		}
		if (list->active_size < ACTIVE) {
			bip_active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeBIPInsert(list, tmp_pg);
		}  
		else {
			unsigned long long candidate_num = 0;
			candidate_num = list->active_tail->page_num;
			bip_active_map.erase(candidate_num);
			activeBIPDeleteTail(list, fp);
			Page candidate_pg = (Page)malloc(sizeof(pageNode));
			candidate_pg->llink = NULL;
			candidate_pg->rlink = NULL;
			candidate_pg->page_num = candidate_num;
			candidate_pg->addr = 0;
			candidate_pg->dirty = 0;
			if(is_write)
				candidate_pg->dirty = 1;

			if (list->candidate_size < CANDIDATE) {
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			else {
				bip_candidate_map.erase(list->candidate_tail->page_num);
				candidateDeleteTail(list);
				bip_candidate_map.insert({ candidate_pg->page_num, candidate_pg });
				candidateInsert(list, candidate_pg);
			}
			bip_active_map.insert({ tmp_pg->page_num, tmp_pg });
			activeBIPInsert(list, tmp_pg);
		}
	}

	if (flag == 0 || flag == 3)
		page_fault++;

	int set = (PAGE + 1) / (SUBPAGE + 1);
	int* sign = (int*)malloc(sizeof(int) * set);
	Page* pg = (Page*)malloc((sizeof(Page) * set));
	int dirty = 0;
	int isPage = 0;
	for (int i = 0; i < set; i++) {
		sign[i] = searchList(list, tmp_page_num / set * set + i, pg[i]);
		if (sign[i] == 2) {
			isPage++;
			if(pg[i]->dirty == 1){
				dirty++;
			}
		}
	}

	if (isPage >= PROMOTE_THRESHOLD)
	{
		Page lru_pg = (Page)malloc(sizeof(pageNode));
		lru_pg->llink = NULL;
		lru_pg->rlink = NULL;
		lru_pg->page_num = tmp_page_num / set;
		lru_pg->addr = 0;
		if(dirty > 0)
			lru_pg->dirty = 1;

		for (int i = 0; i < set; i++)
		{
			if (sign[i] == 2) {
				bip_active_map.erase(pg[i]->page_num);
				if (pg[i]->llink == NULL) {
					if (pg[i]->rlink == NULL) {
						list->active_head = NULL;
						list->active_tail = NULL;
						list->active_size -= 1;
					}
					else {
						list->active_head = pg[i]->rlink;
						pg[i]->rlink->llink = pg[i]->llink;
						list->active_size -= 1;
					}
				}
				else {
					if (pg[i]->rlink == NULL) {
						list->active_tail = pg[i]->llink;
						pg[i]->llink->rlink = pg[i]->rlink;
						list->active_size -= 1;
					}
					else {
						pg[i]->llink->rlink = pg[i]->rlink;
						pg[i]->rlink->llink = pg[i]->llink;
						list->active_size -= 1;
					}
				}
			}
			else if (sign[i] == 1) {
				bip_inactive_map.erase(pg[i]->page_num);
				if (pg[i]->llink == NULL) {
					if (pg[i]->rlink == NULL) {
						list->inactive_head = NULL;
						list->inactive_tail = NULL;
						list->inactive_size -= 1;
					}
					else {
						list->inactive_head = pg[i]->rlink;
						pg[i]->rlink->llink = pg[i]->llink;
						list->inactive_size -= 1;
					}
				}
				else {
					if (pg[i]->rlink == NULL) {
						list->inactive_tail = pg[i]->llink;
						pg[i]->llink->rlink = pg[i]->rlink;
						list->inactive_size -= 1;
					}
					else {
						pg[i]->llink->rlink = pg[i]->rlink;
						pg[i]->rlink->llink = pg[i]->llink;
						list->inactive_size -= 1;
					}
				}
			}
			lru_pg->addr = lru_pg->addr | (pg[i]->addr << (SUBPAGE + 1) * i);
			free(pg[i]);
		}
		if (lru->inactive_size < (LRU_CAPACITY + 1) / 2) {
			lru_inactive_map.insert({ lru_pg->page_num,lru_pg });
			inactiveLRUInsert(lru, lru_pg);
			promote_num++;
		}
		else {
			lru_inactive_map.erase(lru->inactive_tail->page_num);
			inactiveLRUDeleteTail(lru, fp);
			lru_inactive_map.insert({ lru_pg->page_num,lru_pg });
			inactiveLRUInsert(lru, lru_pg);
			promote_num++;
		}
	}
	free(sign);
	free(pg);
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

	Cache cache = (Cache)malloc(sizeof(BIPList) * (INDEX + 1));
	for (int i = 0; i < INDEX + 1; i++) {
		cache[i] = (BIPList)malloc(sizeof(bipList));
		cache[i]->active_size = 0;
		cache[i]->inactive_size = 0;
		cache[i]->candidate_size = 0;
	}
	LRUList lru = (LRUList)malloc(sizeof(lruList));
	lru->active_size = 0;
	lru->inactive_size = 0;

	double line = 0;
	char c = ' ';
	int flag = 0;
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

		if (findLRU(lru, tmp_num, tmp_size, fp, dirty) != 0)
		{
			lru_hit++;
			continue;
		}

		if (offset + tmp_size - 1 <= SUBPAGE) {
			flag = createPage(cache[tmp_group], lru, tmp_page, offset, tmp_size, fp, dirty);
			if (flag == 2) {
				active_hit++;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
			else if (flag == 3) {
				candidate_hit++;
			}
		}
		else {
			flag = createPage(cache[tmp_group], lru, tmp_page, offset, SUBPAGE - offset + 1, fp, dirty);
			if (flag == 2) {
				active_hit++;
			}
			else if (flag == 1) {
				inactive_hit++;
			}
			else if (flag == 3) {
				candidate_hit++;
			}
			tmp_page = tmp_page + 1;
			tmp_size = tmp_size - (SUBPAGE - offset + 1);
			tmp_group = tmp_page & INDEX;
			while (tmp_size > 0) {
				if (tmp_size >= (SUBPAGE + 1)) {
					flag = createPage(cache[tmp_group], lru, tmp_page, 0, SUBPAGE + 1, fp, dirty);
					if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					else if (flag == 3) {
						candidate_hit++;
					}
					tmp_page = tmp_page + 1;
					tmp_size = tmp_size - (SUBPAGE - 0 + 1);
					tmp_group = tmp_page & INDEX;
				}
				else
				{
					flag = createPage(cache[tmp_group], lru, tmp_page, 0, tmp_size, fp, dirty);
					if (flag == 2) {
						active_hit++;
					}
					else if (flag == 1) {
						inactive_hit++;
					}
					else if (flag == 3) {
						candidate_hit++;
					}
					break;
				}
			}
		}
	}

	for (int i = 0; i < INDEX + 1; i++) {
		while (cache[i]->inactive_size) {
			inactiveBIPDeleteTail(cache[i], fp);
		}
		while (cache[i]->active_size) {
			activeBIPDeleteTail(cache[i], fp);
		}
		while (cache[i]->candidate_size) {
			candidateDeleteTail(cache[i]);
		}
		free(cache[i]);
	}
	free(cache);
	while (lru->active_size) {
		activeLRUDeleteTail(lru, fp);
	}
	while (lru->inactive_size) {
		inactiveLRUDeleteTail(lru, fp);
	}
	free(lru);

	fprintf(fp, "#page_fault:  %llu \n", page_fault);
	fprintf(fp, "#userate:  %lf \n", page_used / page_sum);
	fprintf(fp, "#active_hit:  %llu \n", active_hit);
	fprintf(fp, "#inactive_hit:  %llu \n", inactive_hit);
	fprintf(fp, "#candidate_hit:  %llu \n", candidate_hit);
	fprintf(fp, "#LRU_hit: %llu\n", lru_hit);
	fprintf(fp, "#promote_num:  %llu \n", promote_num);
	fprintf(fp, "#write_back_512:  %llu \n", write_back_512);
	fprintf(fp, "#write_back_4k:  %llu \n", write_back_4k);

	fclose(fp);
	fclose(trace);

	return 0;
}
