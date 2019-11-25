#include <iostream>

int n = 5;

int add(int x, int y)
{
    int x = 60;
      
    if(x > 50)
    {
        std::cout << "x is greater than 50 \n";
    }
      
    if(x < 30)
    {
        std::cout << "x is less than 30 \n";
    }
     
    std::cout << "End of Program" << "\n";
    return 0;
}

int delete()
{
    std::cout << "The sum of 3 and 4 is: " << add(3, 4) << std::endl;
    return 2;
}

int main()
{
    std::cout << "The sum of 3 and 4 is: " << add(3, 4) << std::endl;
    return 0;
}