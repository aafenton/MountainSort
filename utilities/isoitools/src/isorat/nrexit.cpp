// $Id: nrexit.cpp,v 1.1 2008/03/19 15:18:38 samn Exp $ 

#include <iostream>
using namespace std;

// Function used to stall exit in Borland C++Builder

void nrexit(void)
{
        cin.get();
        return;
}

#pragma exit nrexit
