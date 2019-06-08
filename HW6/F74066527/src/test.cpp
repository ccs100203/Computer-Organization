#include <iostream>
#include <fstream>
#include <string>
#include <math.h>
#include <vector>
#include <algorithm>
#include <time.h>
using namespace std;

class block {
    public:
        unsigned int index;
        unsigned int tag;
        int time; //record last use time
        int fre; //record use frequence
        int valid;
        int future;
        block(int i){
            this->index = i;
            this->tag = 0;
            this->time = 0;
            this->valid = 0;
            this->fre = 0;
            this->future = 0;
        }
};

int main(int argc, char **argv){
    clock_t tStart = clock();
    fstream fin, fout;
    fin.open(argv[1], ios::in);
    fout.open(argv[2], ios::out|ios::trunc);
    if(!fin || !fout) cerr << "Not File" << endl;
    int cache_size; //KB
    int block_size; //Byte
    int associativity;  //direct-mapped=0, 4-way=1, fully associative=2
    int replacement; // FIFO=0 , LRU=1, Your Policy=2
    int index_bit;

    fin >> cache_size >> block_size >> associativity >> replacement;
    int index_len = cache_size*1024 / block_size;
    // vector<block> *vec;
    if(associativity == 0){
        index_bit = log2(index_len);
        // vec = new vector<block>[index_len];
    }else if(associativity == 1){
        index_bit = log2(index_len/4);
        // vec = new vector<block>[index_len/4];
    }else{
        index_bit = log2(1);
        // vec = new vector<block>[1];
    }
    vector<block> vec;
    for(int i=0; i<index_len; ++i)
        vec.push_back(block(i));
    int offset_bit = log2(block_size);
    int tag_bit = 32 - offset_bit - index_bit;
    // cout << "cache_size: " << cache_size << endl;
    // cout << "block_size: " << block_size << endl;
    // cout << "associativity: " << associativity << endl;
    // cout << "replacement: " << replacement << endl;
    // cout << "index_len: " << index_len << endl;
    // cout << "index_bit: " << index_bit << endl;
    // cout << "offset_bit: " << offset_bit << endl;
    // cout << "tag_bit: " << tag_bit << endl;
    
    unsigned int temp;
    vector<unsigned int>tag_vec, index_vec;
    while(fin >> hex >> temp){
        temp>>=offset_bit;
        tag_vec.push_back(temp>>index_bit);
        index_vec.push_back(temp ^ ((temp>>index_bit)<<index_bit));
    }

    fin.close();
    fin.open(argv[1], ios::in);
    int trash;
    fin >>trash>>trash>>trash>>trash;

    int times = 0;
    bool flag = false;
    while(fin >> hex >> temp){
        flag = false;
        times++;
        temp>>=offset_bit;
        const unsigned int tag_i = temp>>index_bit;
        const unsigned int index_i = temp ^ ((temp>>index_bit)<<index_bit);

        if(associativity == 0){ //1-way
            if(vec.at(index_i).valid == 0 || vec.at(index_i).tag == tag_i){ //hit
                vec.at(index_i).valid = 1;
                vec.at(index_i).tag = tag_i;
                fout << -1 << endl;
            }else{ //miss
                fout << vec.at(index_i).tag << endl;
                vec.at(index_i).tag = tag_i;
            }
        }else{
            int search, end;
            if(associativity == 1){ //4-way
                search = index_i*4;
                end = search+4;
            }else{ //fully-way
                search = 0;
                end = index_len;
            }
            for(int i =search; i<end; ++i){ //hit
                 if(vec.at(i).valid == 0 || (vec.at(i).tag == tag_i && vec.at(i).valid == 1)){
                    vec.at(i).tag = tag_i;
                    fout << -1 << endl;
                    flag = true;
                    if(vec.at(i).valid == 0){ //empty
                        vec.at(i).fre = 1;
                        vec.at(i).time = times;
                        vec.at(i).valid = 1;
                        break;
                    }
                    if(replacement != 0) vec.at(i).time = times;
                    vec.at(i).fre += 1;
                    break;
                }
            }
            if(flag) continue;
            int min_val=99999, min_ind=0, max_val = 0;
            if(replacement != 2){ //miss FIFO and LRU
                for(int i =search; i<end; ++i){
                    min_ind = ( vec.at(i).time < min_val)? i : min_ind;
                    min_val = ( vec.at(i).time < min_val)? vec.at(i).time : min_val;
                }
            }else{ //miss Your Policy
                // for(int i =search; i<end; ++i){ //LFU
                //     min_ind = ( vec.at(i).fre < min_val)? i : min_ind;
                //     min_val = ( vec.at(i).fre < min_val)? vec.at(i).fre : min_val;
                //     if(min_val == 1) break;
                // }
                int big = (index_vec.size() < 2060)? index_vec.size() : 2060;
                // int big = index_vec.size();
                for(int i =search; i<end; ++i){
                    vec.at(i).future = 99999;
                    for(int j=times; j<big; ++j){
                        if(vec.at(i).tag==tag_vec.at(j)){
                            vec.at(i).future = j;
                            break;
                        }
                    }
                }
                for(int i =search; i<end; ++i){
                    // min_ind = ( vec.at(i).future < min_val)? i : min_ind;
                    // min_val = ( vec.at(i).future < min_val)? vec.at(i).future : min_val;
                    // if(min_val == 0) break;
                    min_ind = ( vec.at(i).future > max_val)? i : min_ind;
                    max_val = ( vec.at(i).future > max_val)? vec.at(i).future : max_val;
                    if(max_val == 99999) break;
                }

            }
            fout << vec.at(min_ind).tag << endl;
            vec.at(min_ind).time = times;
            vec.at(min_ind).fre = 1;
            vec.at(min_ind).tag = tag_i;
        }
    }
    printf("Time taken: %.2fs\n", (double)(clock() - tStart)/CLOCKS_PER_SEC);
    fin.close();
    fout.close();
    return 0;
}
