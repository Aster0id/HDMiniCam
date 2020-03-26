#pragma once
#include "locale.h"

class UStrToAscChar     //CStringW + wchar_t* -> char*  
{  
public:  
    UStrToAscChar(const CStringW cs)  
    {  
        int n = WideCharToMultiByte(CP_OEMCP,0,cs,-1,NULL,0,NULL,NULL);  
        if(n <= 0)  
            buff = NULL;  
        buff = new char[n];  
        memset(buff,0,n);  
        WideCharToMultiByte(CP_OEMCP,0,cs,-1,buff,n,NULL,NULL);  
    }  
    ~UStrToAscChar()  
    {  
        delete buff;  
    }  
    const char* operator &()    //注意这是成员函数重载了运算符，友元函数重载需要参数  
    {  
        return buff;  
    }  
private:  
    char* buff;  
};  
  
class UStrToWChar       //CStringW ->wchar_t*  
{  
public:  
    UStrToWChar(const CStringW cs)  
    {  
        int n = cs.GetLength();  
        if(n <= 0)  
            buff = NULL;  
        buff = new wchar_t[n + 1];  
        wmemset(buff,0,n + 1);  
        for(int i = 0; i < n; i++)  
            buff[i] = cs[i];  
    }  
    ~UStrToWChar()  
    {  
        delete buff;  
    }  
    const wchar_t* operator &()  
    {  
        return buff;  
    }  
private:  
    wchar_t* buff;  
};  
  
class AStrToAscChar     //CStringA -> char*  
{  
public:  
    AStrToAscChar(const CStringA cs)  
    {  
        int n = cs.GetLength();  
        if(n <= 0)  
            buff = NULL;  
        buff = new char[n + 1];  
        memset(buff,0,n + 1);  
        for(int i = 0; i < n; i++)  
            buff[i] = cs[i];  
    }  
    ~AStrToAscChar()  
    {  
        delete buff;  
    }  
    const char* operator &()  
    {  
        return buff;  
    }  
private:  
    char* buff;  
};  
  
class AscCharToWChar    //char* -> wchar_t*  
{  
public:  
    AscCharToWChar(const char* ac)  
    {  
        if(ac == NULL || strlen(ac) <= 0)  
            buff = NULL;  
        int n = MultiByteToWideChar(CP_ACP,0,ac,-1,NULL,0);  
        buff = new wchar_t[n];  
        wmemset(buff,0,n);  
        MultiByteToWideChar(CP_ACP,0,ac,-1,buff,n);  
    }  
    ~AscCharToWChar()  
    {  
        delete buff;  
    }  
    const wchar_t* operator &()  
    {  
        return buff;  
    }  
private:  
    wchar_t* buff;  
};  

class Console  
{  
public:  
    Console()  
    {  
        AllocConsole();  
        freopen_s(&fp,"conout$","w",stdout);    //打开控制台  
  
        setlocale(LC_ALL,"chs");  
    }  
private:  
    FILE *fp;  
};
