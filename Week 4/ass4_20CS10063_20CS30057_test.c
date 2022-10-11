/**
 * 		Spandan Halder - 20CS10063
 * 		Utsav Basu 	   - 20CS30057
 */

inline void function1(int *restrict p1, int c[static 9], volatile int p3, int e[const 3])
{
	auto int a;
	register int b;
	extern int c;
	static int d = 4;
}

const char *hello2(int b[const static 8], const int p2, int d[], ...);

inline const long unsigned int ***bye_bye(const char *restrict rec, char **restrict send);

enum e1;

enum e2
{
	POSITION1,
	POSITION2
};

enum
{
	POSITION3 = 100,
	POSITION4,
	POSITION5,
	POSITION6,
	POSITION7,
	POSITION8,
} e3;

void reverse(char str[20], int len, char dest[20]);

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

signed main()
{
	int a[6] = {1, 2, [2] = 3};
	char b[] = "hello world";
	char c1 = 'c';
	char *c2 = &c1;
	*c2 = 'a';
	char **d = (char){"a", b, "abc"};

	int n0 = -3452;
	unsigned long n1 = +94570275;
	short n2 = ~46;
	float n3 = -23.86532;
	double n4 = 928e-23;
	_Bool n5 = !5;
	double _Complex n6;
	double _Imaginary n7;

	n1 = (unsigned int)c;
	n1 = sizeof(long double);
	n1 = sizeof n1;

	n1 *= n1, n1 /= n1, n1 %= n1;
	n1 += (n1 -= (n1 <<= (n1 >>= n1)));
	n1 &= n1 |= n1 ^= n1;

	n1 = ((n1 == 0 && n1 == 1) && !(n1 != n2)) ? n1 = 7 : n2;
	a[n2 << n1 >> n2] = n1 >> n2 << n1;

RANDOM_LOC:

	if (!n5)
	{
		switch (n2)
		{
		case 0:
			n2++;
			break;
		case 1:
			n2 /= 4;
			break;
		default:
			n2--;
		}
	}
	else if (n3 > n4)
	{
		if (n2 <= n1)
			n1++;
		++n2;
	}
	else
	{
		if (n2 >= n1)
			n2++;
		++n1;
	}

	while (n2--)
		goto RANDOM_LOC;

	for (; 1;)
		for (int i;; ++i)
			for (int i = 0, j = 1; i != j; i++)
			{
				if (j == 1)
					continue;
			}

	do
	{
		n0++;
		++n0;

	} while (!(n0 >= 0));

	int var1, var2, var3, var4, var5, var6;

	var1 = var1 - var2 + var3 / var2 - var4 * var5 / var6 % 23;
	var2 = var2 << 6;
	var2 = var2 >> 8;
	var1 = var2 | var3 | var4 ^ var5 & var6 ^ var1;

	function1(1, 2, 3, 4);

	/* testing . and -> */
	ms1.a = 3;
	ms2->a = 4;

	return 0;
}
