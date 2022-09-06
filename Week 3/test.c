/**
 * NODE : _node => typedef for _node
 * @struct _node : base struct for node
 */
typedef struct _node
{
	int value;			// value
	struct _node *next; // next pointer
} NODE;

/**
 * LLIST : _list* => typedef for _list*
 * @struct _list : base struct for linked-list
 */
typedef struct _list
{
	NODE head;	// head node
	NODE *tail; // tail pointer
} * LLIST;

NODE *createNode(int k, NODE *ptr)
{
	NODE *temp = malloc(sizeof *temp);
	temp->value = k;
	temp->next = ptr;

	return temp;
}

/**
 * Creates an empty linked list, and returns it.
 * @return LLIST : empty linked-list
 */
LLIST createList()
{
	LLIST list = malloc(sizeof *list);
	list->head.value = 0;
	list->head.next = NULL;
	list->tail = &list->head;

	return list;
}

/**
 * Checks if list is empty.
 * @param H : LLIST => list on which the operation is to be performed
 * @return int : 1 if empty, 0 otherwise
 */
int isEmptyList(LLIST H)
{
	return H->tail == &H->head;
}



int main()
{
	char FName[1001] = {'\0'};
	printf("Enter Path of File : ");
	scanf(" %[^\n]c", FName);

	GRAPH G = readGraph(FName);

	printf("DFS : ");
	DFS(G);
	printf("BFS : ");
	BFS(G);
	printf("MST :\n");
	MST(G);

	unsigned long int i_12 = 10;
	double d = 12.5;
	char c = 'h';
	
}
