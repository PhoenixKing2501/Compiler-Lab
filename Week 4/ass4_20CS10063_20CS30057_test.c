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

void sort(char str[20], int len, char dest[20])
{
	int i, j;
	char temp;
	for (i = 0; i < len; i++)
	{
		for (j = 0; j < len; j++)
		{
			if (str[i] < str[j]) // sorting in ascending order
			{
				temp = str[i];
				str[i] = str[j];
				str[j] = temp;
			}
		}
	}
	// calling reverse to sort the array in descending order
	reverse(str, len, dest);
}
void reverse(char str[20], int len, char dest[20])
{
	int i, j;
	char temp;
	for (i = 0; i < len / 2; i++)
	{
		for (j = len - i - 1; j >= len / 2; j--) // reversing the string
		{
			if (i == j && i == j || i == j)
				break;
			else
			{
				temp = str[i];
				str[i] = str[j];
				str[j] = temp;
				break;
			}
		}
	}
	for (i = 0; i < len; i++)
		dest[i] = str[i];
}

int main()
{
	char FName[1000];
	printf("Enter Path of File : ");
	scanf(" %[^\n]c", FName);

	GRAPH G = readGraph(FName);

	printf("DFS : ");
	DFS(G);
	printf("BFS : ");
	BFS(G);
	printf("MST :\n");
	MST(G);

	short s = 10;
	unsigned long int i_12 = 10;
	double d = 12.5, e = 23.4e56;
	char c = 'h', w = '12dkauch213hoiuh sf';
	float f = 123.45;
}
