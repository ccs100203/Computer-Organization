#include <iostream>
#include <fstream>
#include <string>
#include <bitset>
#include <sstream>
#include <math.h>
#include <vector>
#include <algorithm>
using namespace std;

class block {
    public:
        int index;
        int tag;
        int offset;
        int time; //record last use time
        int fre; //record use frequence
        int valid;
        int future;
        block(int i){
            this->index = i;
            this->tag = 0;
            this->offset = 0;
            this->time = 0;
            this->valid = 0;
            this->fre = 0;
            this->future = 0;
        }
};

int main(int argc, char **argv){
    stringstream ss;
    fstream fin, fout;
    fin.open(argv[1], ios::in);
    fout.open(argv[2], ios::out|ios::trunc);
    if(!fin || !fout) cerr << "Not File" << endl;
    int cache_size; //KB
    int block_size; //Byte
    int associativity;  //direct-mapped=0, 4-way=1, fully associative=2
    int replacement; // FIFO=0 , LRU=1, Your Policy=2
    int index_len;
    int index_bit;

    fin >> cache_size >> block_size >> associativity >> replacement;
    cout << "cache_size: " << cache_size << endl;
    cout << "block_size: " << block_size << endl;
    cout << "associativity: " << associativity << endl;
    cout << "replacement: " << replacement << endl;
    index_len = cache_size*1024 / block_size;
    if(associativity == 0)
        index_bit = log2(cache_size*1024 / block_size);
    else if(associativity == 1)
        index_bit = log2(cache_size*1024 / (block_size*4));
    else
        index_bit = log2(1);
    
    cout << "index_len: " << index_len << endl;
    cout << "index_bit: " << index_bit << endl;
    vector<block> vec;
    for(int i=0; i<index_len; ++i)
        vec.push_back(block(i));
    int offset_bit = log2(block_size);
    cout << "offset_bit: " << offset_bit << endl;
    int tag_bit = 32 - offset_bit - index_bit;
    cout << "tag_bit: " << tag_bit << endl;
    
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

    string str_h;
    int times = 0;
    bool flag = false;
    while(fin >> str_h){
        flag = false;
        times++;
        ss << hex << str_h;
        unsigned unsign;
        ss >> unsign;
        bitset<32> bin(unsign);
        ss.clear();

        string index_s="";
        string tag_s="";
        int index_i=0;
        int tag_i=0;

        for(int i=31; i > 31-tag_bit; --i)
            tag_s += to_string(bin[i]);
        for(int i=31-tag_bit; i >= offset_bit; --i)
            index_s += to_string(bin[i]);
        index_i = (index_s != "")? stoi(index_s, nullptr, 2) : 0;
        tag_i = stoi(tag_s, nullptr, 2);

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
            tag_vec.erase(tag_vec.begin());
            index_vec.erase(index_vec.begin());
            for(int i=0; i<vec.size();++i)
                vec.at(i).future = 0;
            for(int i =search; i<end; ++i){ //exist
                if(vec.at(i).tag == tag_i && vec.at(i).valid == 1){
                    if(replacement != 0) vec.at(i).time = times;
                    vec.at(i).fre += 1;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            for(int i =search; i<end; ++i){ //has empty block
                if(vec.at(i).valid == 0){
                    vec.at(i).valid = 1;
                    vec.at(i).tag = tag_i;
                    vec.at(i).time = times;
                    vec.at(i).fre = 1;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            int min_val=99999, min_ind=0;
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
                int min_val=99999, min_ind=0;
                int big;
                big = (index_vec.size() < 200)? index_vec.size() : 200;
                for(int i =search; i<end; ++i){
                    for(int j=0; j<big; ++j){
                        if(i==index_vec.at(j) && vec.at(i).tag==tag_vec.at(j))
                            vec.at(i).future+=1;
                    }
                    min_ind = ( vec.at(i).future < min_val)? i : min_ind;
                    min_val = ( vec.at(i).future < min_val)? vec.at(i).future : min_val;
                    if(min_val == 0) break;
                }

            }
            fout << vec.at(min_ind).tag << endl;
            vec.at(min_ind).time = times;
            vec.at(min_ind).fre = 1;
            vec.at(min_ind).tag = tag_i;
        }
    }

    fin.close();
    fout.close();
    return 0;
}
