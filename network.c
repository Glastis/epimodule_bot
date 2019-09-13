//
// Created by glastis on 9/13/19.
//

#include <curl/curl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct curl_slist s_header;

#define HEADER_USER_KEY     "user: "
#define HEADER_GDPR         "gdpr: 0"

static char             *test;

static void             my_memcpy(char *dest, const char *from, unsigned int n)
{
    unsigned int        i;

    i = 0;
    while (i < n)
    {
        dest[i] = from[i];
        ++i;
    }
}

static size_t           write_callback(void *ptr, size_t size, size_t nmemb, char **data)
{
    data[0] = malloc(size * (nmemb + 1));
    my_memcpy(data[0], ptr, size * nmemb);
    data[0][size * nmemb] = '\0';
    return 0;
}

char                    *concat(char *str1, char *str2)
{
    char                *new;
    unsigned int        len1;
    unsigned int        len2;

    len1 = strlen(str1);
    len2 = strlen(str2);
    new = malloc(len1 + len2 + 1);
    memcpy(new, str1, len1);
    memcpy(&new[len1], str2, len2);
    new[len1 + len2] = '\0';
    return new;
}

s_header                *get_header_token(char *token)
{
    s_header            *chunk;
    char                *tmp;

    tmp = concat(HEADER_USER_KEY, token);
    chunk = curl_slist_append(NULL, tmp);
    free(tmp);
    chunk = curl_slist_append(chunk, HEADER_GDPR);
    return chunk;
}

int                     request(char *url, char *token, char **ret)
{
    CURL                *curl;
    CURLcode            res;
    s_header            *chunk;
    long int            response_code;

    ret[0] = NULL;
    curl = curl_easy_init();
    if (curl)
    {
        chunk = get_header_token(token);
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, ret);
        res = curl_easy_perform(curl);
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
        printf("%ld\n", response_code);
        if(res != CURLE_OK)
            fprintf(stderr, "curl_easy_perform() failed: %s\n",
                    curl_easy_strerror(res));
        curl_easy_cleanup(curl);
        return res != CURLE_OK;
    }
    return -1;
}

int                     main(int ac, char **av)
{
    char                *page;

    request(av[1], av[2], &page);
    if (page)
    {
        puts(page);
        free(page);
    }
}