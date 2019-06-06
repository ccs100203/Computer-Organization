#include <iostream>
#include <fstream>
#include <string>
#include <bitset>
#include <sstream>
#include <math.h>
#include <vector>
using namespace std;

string hex_char_to_bin(char c);
string hex_str_to_bin_str(const std::string& hex);

class block {
    public:
        int index;
        int tag;
        int offset;
        int time;
        int valid;
        block(int i){
            this->index = i;
            this->tag = 0;
            this->offset = 0;
            this->time = 0;
            this->valid = 0;
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
    int associativity;
    int replacement; // FIFO=0 , LRU=1, Your Policy=2
    int index_len;
    int index_bit;

    fin >> cache_size;
    fin >> block_size;
    fin >> associativity;
    fin >> replacement;
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
    
    string str_h;
    int times = 0;
    bool flag = false;
    while(fin >> str_h){
        // cout << times << endl;
        flag = false;
        times++;
        ss << hex << str_h;
        unsigned unsign;
        ss >> unsign;
        bitset<32> bin(unsign);
        // fout << bin << endl;
        ss.clear();

        string index_s="";
        string tag_s="";
        int index_i=0;
        int tag_i=0;
        for(int i=31; i > 31-tag_bit; --i){
            tag_s += to_string(bin[i]);
        }
        for(int i=31-tag_bit; i >= offset_bit; --i){
            index_s += to_string(bin[i]);
            // cout << int(bin[i]) << endl;
        }
        if(index_s != "")
            index_i = stoi(index_s, nullptr, 2);
        tag_i = stoi(tag_s, nullptr, 2);
        // cout <<tag_i <<endl;
        if(associativity == 0){ //1-way
            
            if(vec.at(index_i).valid == 0 || vec.at(index_i).tag == tag_i){ //hit
                vec.at(index_i).valid = 1;
                vec.at(index_i).tag = tag_i;
                fout << -1 << endl;
            }
            else{ //miss
                fout << vec.at(index_i).tag << endl;
                vec.at(index_i).tag = tag_i;
            }
            // cout <<"  "<< index_i << endl;
        }else if(associativity == 2){ //fully-way
            // cout<< tag_i <<endl;
            // cout<< vec.size() <<endl;
            for(int i=0; i<index_len; ++i){ //exist
                if(vec.at(i).tag == tag_i && vec.at(i).valid == 1){
                    vec.at(i).time = times;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            for(int i=0; i<index_len; ++i){ //has empty block
                if(vec.at(i).valid == 0){
                    vec.at(i).valid = 1;
                    vec.at(i).tag = tag_i;
                    vec.at(i).time = times;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            int min_val=99999, min_ind=0;
            for(int i=0; i<index_len; ++i){ //miss
                min_ind = ( vec.at(i).time < min_val)? i : min_ind;
                min_val = ( vec.at(i).time < min_val)? vec.at(i).time : min_val;
            }
            fout << vec.at(min_ind).tag << endl;
            vec.at(min_ind).time = times;
            vec.at(min_ind).tag = tag_i;
        }else if(associativity == 1){ //4-way
            // cout << index_i << endl;
            int search = index_i*4;
            for(int i =search; i<search+4; ++i){ //exist
                if(vec.at(i).tag == tag_i && vec.at(i).valid == 1){
                    vec.at(i).time = times;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            for(int i =search; i<search+4; ++i){ //has empty block
                if(vec.at(i).valid == 0){
                    vec.at(i).valid = 1;
                    vec.at(i).tag = tag_i;
                    vec.at(i).time = times;
                    fout << -1 << endl;
                    flag = true;
                    break;
                }
            }
            if(flag) continue;
            int min_val=99999, min_ind=0;
            for(int i =search; i<search+4; ++i){ //miss
                min_ind = ( vec.at(i).time < min_val)? i : min_ind;
                min_val = ( vec.at(i).time < min_val)? vec.at(i).time : min_val;
            }
            fout << vec.at(min_ind).tag << endl;
            vec.at(min_ind).time = times;
            vec.at(min_ind).tag = tag_i;
        }
    }

    return 0;
}
