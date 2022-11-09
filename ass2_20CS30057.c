/**
 * file:     ass_20CS30057.c
 * Name:     Utsav Basu
 * Roll No.: 20CS30057
 */

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

int readFlt(float *f)
{
	int f_len = 8, bytes = BUFF, i = 0, j, dig, flag,
		num_i = 0, prod_10 = 1, num_f = 0;

	char buff[BUFF] = "";

	asm volatile(
		"movl $0, %%eax \n\t"
		"movq $0, %%rdi \n\t"
		"syscall \n\t"
		:
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

	for (; buff[i] != '.'; ++i)
	{
		if (!(buff[i] >= '0' && buff[i] <= '9'))
		{
			*f = 0.0f;
			return ERR;
		}

		dig = buff[i] - '0';
		num_i *= 10;
		num_i += dig;
	}

	++i;

	for (j = i; buff[i] != '\0' && buff[i] != '\n' && (i - j) < f_len; ++i)
	{
		if (!(buff[i] >= '0' && buff[i] <= '9'))
		{
			*f = 0;
			return ERR;
		}

		dig = buff[i] - '0';
		num_f *= 10;
		num_f += dig;
	}

	f_len = ((i - j) < f_len ? (i - j) : f_len);

	for (i = 0; i < f_len; i += 1, prod_10 *= 10)
		;

	*f = num_i + (float)num_f / (float)prod_10;
	*f *= (flag ? -1.0 : 1.0);

	return OK;
}

int printFlt(float f)
{
	char str[] = "000000";
	int i, k, fi, n1, n2, n3, n4, dig, flag;

	if (f < 0)
	{
		flag = 1;
		f = -f;
	}
	else
	{
		flag = 0;
	}

	i = (int)f;
	f -= (float)i;
	fi = (int)(f * 1e6f);

	fi = (fi < 0 ? -fi : fi);

	for (k = 5; k >= 0; --k)
	{
		dig = fi % 10;
		str[k] = (char)('0' + dig);
		fi /= 10;
	}

	n1 = (flag ? printStr("-") : 0);
	n2 = printInt(i);
	n3 = printStr(".");
	n4 = printStr(str);

	return n1 + n2 + n3 + n4;
}
