#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

void* worker(void* arg) {
    int thread_num = *(int*)arg;
    printf("Thread %d: started\n", thread_num);
    sleep(3);

    if (thread_num == 2) {
        int *ptr = NULL;
        printf("Thread %d: about to crash!\n", thread_num);
        *ptr = 42; // crash here
    }

    printf("Thread %d: finished\n", thread_num);
    return NULL;
}

int main() {
    pthread_t threads[3];
    int thread_nums[3] = {1, 2, 3};

    for (int i = 0; i < 3; i++) {
        pthread_create(&threads[i], NULL, worker, &thread_nums[i]);
    }

    for (int i = 0; i < 3; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All threads finished\n");
    return 0;
}