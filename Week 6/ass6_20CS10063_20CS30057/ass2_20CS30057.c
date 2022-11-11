#include "myl.h"
#define BUFF 1024

int printStr(char *buff)
{
	int len, bytes;

	for (bytes = 0; buff[bytes] != 0; ++bytes)
		;

	asm volatile(
		"movl $1, %%eax \n\t"
		"movq $1, %%rdi \n\t"
		"syscall \n\t"
		: "=a"(len)
		: "S"(buff), "d"(bytes));

	return len;
}

int readInt(int *n)
{
	int len, bytes = BUFF, i = 0, dig, flag, num = 0;
	char buff[BUFF] = "";

	asm volatile(
		"movl $0, %%eax \n\t"
		"movq $0, %%rdi \n\t"
		"syscall \n\t"
		: "=a"(len)
		: "S"(buff), "d"(bytes));

	if (buff[0] == '-')
	{
		++i;
		flag = 1;
	}
	else
	{
		flag = 0;
	}

	for (; buff[i] != '\0' && buff[i] != '\n'; ++i)
	{
		if (!(buff[i] >= '0' && buff[i] <= '9'))
		{
			*n = 0;
			return ERR;
		}

		dig = buff[i] - '0';
		num *= 10;
		num += dig;
	}

	num *= (flag ? -1 : 1);
	*n = num;

	return OK;
}

int printInt(int n)
{
	char buff[BUFF] = "";
	int i = 0, j, k, bytes, len;

	if (n == 0)
	{
		buff[i++] = '0';
	}
	else
	{
		if (n < 0)
		{
			buff[i++] = '-';
			n = -n;
		}
		while (n)
		{
			int dig = n % 10;
			buff[i++] = (char)('0' + dig);
			n /= 10;
		}

		if (buff[0] == '-')
		{
			j = 1;
		}
		else
		{
			j = 0;
		}

		k = i - 1;

		while (j < k)
		{
			char temp = buff[j];
			buff[j++] = buff[k];
			buff[k--] = temp;
		}
	}

	bytes = i;

	asm volatile(
		"movl $1, %%eax \n\t"
		"movq $1, %%rdi \n\t"
		"syscall \n\t"
		: "=a"(len)
		: "S"(buff), "d"(bytes));

	return len;
}
