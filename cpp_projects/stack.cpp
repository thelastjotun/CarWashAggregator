#include <iostream>

#define NMAX 100

using namespace std;

typedef int element;

struct Stack
{
    element data[NMAX];
    int size;
};

bool isEmpty(Stack s) {
    if (s.size == 0) {
        return true;
    }

    return false;
}

void init(Stack& s) {
    s.size = 0;
}

void pop(Stack& s) {
    if (isEmpty(s)) {
        cout << "Stack is empty!" << endl;
    } else {
        cout << s.data[s.size - 1] << " was poped" << endl;
        s.size--;
    }
}

void push(Stack& s, element e) {
    if(s.size < NMAX) {
        s.data[s.size++] = e;
    } else {
        cout << "Stack is full!" << endl;
    }
}

void pip(Stack& s) {
    if (isEmpty(s)) {
        cout << "Stack is empty!" << endl;
    } else {
        for (int i = 0; i < s.size; i++)
        {
            cout << s.data[i] << " ";
        }
        cout << endl;
    }
}

int main() {
    Stack s;

    init(s);

    char expression;

    while (true)
    {
        cout << "Which expression would you like?" << endl
        << "1. push" << endl 
        << "2. pop" << endl
        << "3. pip" << endl
        << "4. exit" << endl
        << "expression: ";

        cin >> expression;

        switch (expression)
        {
        case '1':
            element x;
            cout << "push: ";
            cin >> x;
            push(s, x);
            break;
        case '2':
            pop(s);
            break;
        case '3':
            pip(s);
            break;
        case '4':
            return 0;
            break;
        default:
            cout << "Wrong expression!" << endl;
            break;
        }
    }
    
    return 0;
}