unit Utils;

interface

uses
  Types;

// Хеш-функция для строки
function HashFunction(const Key: string): Integer;

// Создание нового списка строк
function CreateStringList: PStringList;

// Добавление строки в список
procedure AddString(List: PStringList; const Str: string);

// Освобождение памяти, занятой списком строк
procedure FreeStringList(List: PStringList);

// Создание нового списка подтерминов
function CreateSubtermList: PSubtermList;

// Добавление подтермина в список
procedure AddSubtermToList(List: PSubtermList; Subterm: PSubterm);

// Освобождение памяти, занятой списком подтерминов
procedure FreeSubtermList(List: PSubtermList);

// Создание нового списка терминов
function CreateTermList: PTermList;

// Добавление термина в список
procedure AddTermToList(List: PTermList; Term: PTerm);

// Освобождение памяти, занятой списком терминов
procedure FreeTermList(List: PTermList);

// Создание нового термина
function CreateTerm(const Name: string; PageNumber: Integer): PTerm;

// Создание нового подтермина
function CreateSubterm(const Name: string; PageNumber: Integer): PSubterm;

// Сортировка терминов по алфавиту
procedure SortTermsByAlphabet(var Terms: PTermList);

// Сортировка терминов по номеру страницы
procedure SortTermsByPage(var Terms: PTermList);

// Сортировка подтерминов по алфавиту
procedure SortSubtermsByAlphabet(var Subterms: PSubtermList);

// Сортировка подтерминов по номеру страницы
procedure SortSubtermsByPage(var Subterms: PSubtermList);

implementation

// Хеш-функция для строки
function HashFunction(const Key: string): Integer;
var
  i, hash: Integer;
begin
  hash := 0;
  for i := 1 to Length(Key) do
    hash := (hash * 31 + Ord(Key[i])) mod TABLE_SIZE;
  HashFunction := hash;
end;

// Создание нового списка строк
function CreateStringList: PStringList;
var
  list: PStringList;
begin
  New(list);
  list^.Count := 0;
  SetLength(list^.Items, 0);
  CreateStringList := list;
end;

// Добавление строки в список
procedure AddString(List: PStringList; const Str: string);
var
  i: Integer;
begin
  // Проверяем, есть ли уже такая строка в списке
  for i := 0 to List^.Count - 1 do
    if List^.Items[i] = Str then
      Exit;
  
  // Добавляем строку
  SetLength(List^.Items, List^.Count + 1);
  List^.Items[List^.Count] := Str;
  Inc(List^.Count);
end;

// Освобождение памяти, занятой списком строк
procedure FreeStringList(List: PStringList);
begin
  SetLength(List^.Items, 0);
  Dispose(List);
end;

// Создание нового списка подтерминов
function CreateSubtermList: PSubtermList;
var
  list: PSubtermList;
begin
  New(list);
  list^.Count := 0;
  SetLength(list^.Items, 0);
  CreateSubtermList := list;
end;

// Добавление подтермина в список
procedure AddSubtermToList(List: PSubtermList; Subterm: PSubterm);
var
  i: Integer;
begin
  // Проверяем, есть ли уже такой подтермин в списке
  for i := 0 to List^.Count - 1 do
    if List^.Items[i] = Subterm then
      Exit;
  
  // Добавляем подтермин
  SetLength(List^.Items, List^.Count + 1);
  List^.Items[List^.Count] := Subterm;
  Inc(List^.Count);
end;

// Освобождение памяти, занятой списком подтерминов
procedure FreeSubtermList(List: PSubtermList);
begin
  SetLength(List^.Items, 0);
  Dispose(List);
end;

// Создание нового списка терминов
function CreateTermList: PTermList;
var
  list: PTermList;
begin
  New(list);
  list^.Count := 0;
  SetLength(list^.Items, 0);
  CreateTermList := list;
end;

// Добавление термина в список
procedure AddTermToList(List: PTermList; Term: PTerm);
var
  i: Integer;
begin
  // Проверяем, есть ли уже такой термин в списке
  for i := 0 to List^.Count - 1 do
    if List^.Items[i] = Term then
      Exit;
  
  // Добавляем термин
  SetLength(List^.Items, List^.Count + 1);
  List^.Items[List^.Count] := Term;
  Inc(List^.Count);
end;

// Освобождение памяти, занятой списком терминов
procedure FreeTermList(List: PTermList);
begin
  SetLength(List^.Items, 0);
  Dispose(List);
end;

// Создание нового термина
function CreateTerm(const Name: string; PageNumber: Integer): PTerm;
var
  term: PTerm;
begin
  New(term);
  term^.Name := Name;
  term^.PageNumber := PageNumber;
  term^.Subterms := CreateSubtermList;
  term^.Next := nil;
  CreateTerm := term;
end;

// Создание нового подтермина
function CreateSubterm(const Name: string; PageNumber: Integer): PSubterm;
var
  subterm: PSubterm;
begin
  New(subterm);
  subterm^.Name := Name;
  subterm^.PageNumber := PageNumber;
  subterm^.ParentTerms := CreateStringList;
  subterm^.Children := CreateSubtermList;
  subterm^.Next := nil;
  CreateSubterm := subterm;
end;

// Сортировка терминов по алфавиту
procedure SortTermsByAlphabet(var Terms: PTermList);
var
  i, j: Integer;
  temp: PTerm;
begin
  for i := 0 to Terms^.Count - 2 do
    for j := 0 to Terms^.Count - i - 2 do
      if Terms^.Items[j]^.Name > Terms^.Items[j + 1]^.Name then
      begin
        temp := Terms^.Items[j];
        Terms^.Items[j] := Terms^.Items[j + 1];
        Terms^.Items[j + 1] := temp;
      end;
end;

// Сортировка терминов по номеру страницы
procedure SortTermsByPage(var Terms: PTermList);
var
  i, j: Integer;
  temp: PTerm;
begin
  for i := 0 to Terms^.Count - 2 do
    for j := 0 to Terms^.Count - i - 2 do
      if Terms^.Items[j]^.PageNumber > Terms^.Items[j + 1]^.PageNumber then
      begin
        temp := Terms^.Items[j];
        Terms^.Items[j] := Terms^.Items[j + 1];
        Terms^.Items[j + 1] := temp;
      end;
end;

// Сортировка подтерминов по алфавиту
procedure SortSubtermsByAlphabet(var Subterms: PSubtermList);
var
  i, j: Integer;
  temp: PSubterm;
begin
  for i := 0 to Subterms^.Count - 2 do
    for j := 0 to Subterms^.Count - i - 2 do
      if Subterms^.Items[j]^.Name > Subterms^.Items[j + 1]^.Name then
      begin
        temp := Subterms^.Items[j];
        Subterms^.Items[j] := Subterms^.Items[j + 1];
        Subterms^.Items[j + 1] := temp;
      end;
end;

// Сортировка подтерминов по номеру страницы
procedure SortSubtermsByPage(var Subterms: PSubtermList);
var
  i, j: Integer;
  temp: PSubterm;
begin
  for i := 0 to Subterms^.Count - 2 do
    for j := 0 to Subterms^.Count - i - 2 do
      if Subterms^.Items[j]^.PageNumber > Subterms^.Items[j + 1]^.PageNumber then
      begin
        temp := Subterms^.Items[j];
        Subterms^.Items[j] := Subterms^.Items[j + 1];
        Subterms^.Items[j + 1] := temp;
      end;
end;

end.