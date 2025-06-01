#ifndef RESTAPI_H
#define RESTAPI_H

#include <iostream>
#include <nlohmann/json.hpp>
#include <pqxx/pqxx>
#include <fstream>
#include <crow.h>
#include <crow/multipart.h>
#include "crow/include/crow/middlewares/cors.h"
#include <mutex>
#include <openssl/sha.h>
#include <jwt-cpp/jwt.h> 
#include <chrono>
#include <string>
#include <filesystem>
#include <unordered_map>
#include <random>
#include <ctime>

using json = nlohmann::json;
using namespace std;
using namespace pqxx;
namespace fs = std::filesystem;

string sha256(const string& str);
string createAccessToken(const string& login);
string createRefreshToken(const string& login);
bool verifyToken(const string& token);
// Функция для обработки ошибок БД
crow::response handle_db_error(const exception& e);
int startServer(pqxx::connection& conn);

#endif //RESTAPI_H
