CC = gcc
CFLAGS = -Wall
LDFLAGS = -lpthread

all: thread sum_thread race mutex scheduler

thread: thread.c
	$(CC) $(CFLAGS) -o thread thread.c $(LDFLAGS)

sum_thread: sum_thread.c
	$(CC) $(CFLAGS) -o sum_thread sum_thread.c $(LDFLAGS)

race: race.c
	$(CC) $(CFLAGS) -o race race.c $(LDFLAGS)

mutex: mutex.c
	$(CC) $(CFLAGS) -o mutex mutex.c $(LDFLAGS)

scheduler: scheduler.c
	$(CC) $(CFLAGS) -o scheduler scheduler.c

clean:
	rm -f thread sum_thread race mutex scheduler