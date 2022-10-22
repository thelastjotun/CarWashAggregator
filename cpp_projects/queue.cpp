#include <iostream>

#define NMAX 100

using namespace std;

typedef int element;

struct queue
{
    element data[NMAX];
    int size;
    int front;    
};

void init(queue &q) {
    q.size = 0;
    q.front = 0;
}

bool isEmpty(queue &q) {
    if (q.size == 0) {
        return true;
    }
    return false;
}

void push(queue &q, element elem) {
    if (q.size < NMAX) {
        q.data[(q.front + q.size++) % NMAX] = elem;
    }
}

void pop(queue &q) {
    if (isEmpty(q)) {
        cout << "Queue is empty!" << endl;
    } else {
        cout << q.data[q.front + 1] << " was poped." << endl;
        q.front = ++q.front % NMAX;
        q.size--;
    }
}

element front(queue &q) {
    if (isEmpty(q)) {
        cout << "Queue is empty!" << endl;
    } else {
        cout << q.data[q.front] << " is the first element." << endl;
    }

    return q.data[q.front];
}

void back(queue &q) {
    if (isEmpty(q)) {
        cout << "Queue is empty!" << endl;
    } else {
        cout << q.data[q.size - 1] << " is the last element." << endl;
    }
}

void pip(queue &q) {
    if (!isEmpty(q)) {
        for (int i = q.front; i % NMAX < q.size; i++) {
            cout << q.data[i] << " ";
        }
        cout << endl;
    }
}

int main() {
    
    queue q;

    init(q);

    char expression;

    while (true)
    {
        cout << "Which expression would you like?" << endl
        << "1. push" << endl 
        << "2. pop" << endl
        << "3. pip" << endl
        << "4. front" << endl
        << "5. back1" << endl        
        << "6. exit" << endl
        << "expression: ";

        cin >> expression;

        switch (expression)
        {
        case '1':
            element x;
            cout << "push: ";
            cin >> x;
            push(q, x);
            break;
        case '2':
            pop(q);
            break;
        case '3':
            pip(q);
            break;
        case '4':
            front(q);
            break;
        case '5':
            back(q);
            break;
        case '6':
            return 0;
            break;
        default:
            cout << "Wrong expression!" << endl;
            break;
        }
    }

    return 0;
}