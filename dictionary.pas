unit Dictionary;

interface

uses
  Types, Utils;

// Инициализация словаря
procedure InitDictionary(var Dict: TDictionary);

// Освобождение памяти, занятой подтермином и его дочерними подтерминами
procedure FreeSubterm(Subterm: PSubterm);

// Освобождение памяти, занятой термином и его подтерминами
procedure FreeTerm(Term: PTerm);

// Освобождение памяти, занятой словарем
procedure FreeDictionary(var Dict: TDictionary);

// Поиск термина по имени
function FindTerm(const Dict: TDictionary; const Name: string): PTerm;

// Поиск подтермина по имени
function FindSubterm(const Dict: TDictionary; const Name: string): PSubterm;

// Добавление термина
procedure AddTerm(var Dict: TDictionary; const Name: string; PageNumber: Integer);

// Добавление подтермина к термину
procedure AddSubtermToTerm(var Dict: TDictionary; const TermName, SubtermName: string; PageNumber: Integer);

// Добавление подтермина к подтермину
procedure AddSubtermToSubterm(var Dict: TDictionary; const ParentSubtermName, SubtermName: string; PageNumber: Integer);

// Поиск всех терминов, содержащих указанный подтермин
function FindTermsBySubterm(const Dict: TDictionary; const SubtermName: string): PTermList;

// Поиск всех подтерминов указанного термина
function FindSubtermsByTerm(const Dict: TDictionary; const TermName: string): PSubtermList;

// Вывод подтермина и его дочерних подтерминов
procedure PrintSubterm(const Subterm: PSubterm; Level: Integer);

// Вывод термина и его подтерминов
procedure PrintTerm(const Term: PTerm);

// Вывод всего словаря
procedure PrintDictionary(const Dict: TDictionary; SortByPage: Boolean);

// Заполнение словаря примерами
procedure FillDictionaryWithExamples(var Dict: TDictionary);

implementation

// Инициализация словаря
procedure InitDictionary(var Dict: TDictionary);
var
  i: Integer;
begin
  for i := 0 to TABLE_SIZE - 1 do
  begin
    Dict.Terms[i] := nil;
    Dict.Subterms[i] := nil;
  end;
end;

// Освобождение памяти, занятой подтермином и его дочерними подтерминами
procedure FreeSubterm(Subterm: PSubterm);
var
  i: Integer;
begin
  if Subterm = nil then
    Exit;
  
  // Освобождаем память, занятую дочерними подтерминами
  for i := 0 to Subterm^.Children^.Count - 1 do
    FreeSubterm(Subterm^.Children^.Items[i]);
  
  // Освобождаем память, занятую списками
  FreeStringList(Subterm^.ParentTerms);
  FreeSubtermList(Subterm^.Children);
  
  // Освобождаем память, занятую самим подтермином
  Dispose(Subterm);
end;

// Освобождение памяти, занятой термином и его подтерминами
procedure FreeTerm(Term: PTerm);
begin
  if Term = nil then
    Exit;
  
  // Освобождаем память, занятую списком подтерминов
  FreeSubtermList(Term^.Subterms);
  
  // Освобождаем память, занятую самим термином
  Dispose(Term);
end;

// Освобождение памяти, занятой словарем
procedure FreeDictionary(var Dict: TDictionary);
var
  i: Integer;
  currentTerm, tempTerm: PTerm;
  currentSubterm, tempSubterm: PSubterm;
begin
  // Освобождаем память, занятую терминами
  for i := 0 to TABLE_SIZE - 1 do
  begin
    currentTerm := Dict.Terms[i];
    while currentTerm <> nil do
    begin
      tempTerm := currentTerm;
      currentTerm := currentTerm^.Next;
      FreeTerm(tempTerm);
    end;
    Dict.Terms[i] := nil;
  end;
  
  // Освобождаем память, занятую подтерминами
  for i := 0 to TABLE_SIZE - 1 do
  begin
    currentSubterm := Dict.Subterms[i];
    while currentSubterm <> nil do
    begin
      tempSubterm := currentSubterm;
      currentSubterm := currentSubterm^.Next;
      FreeSubterm(tempSubterm);
    end;
    Dict.Subterms[i] := nil;
  end;
end;

// Поиск термина по имени
function FindTerm(const Dict: TDictionary; const Name: string): PTerm;
var
  index: Integer;
  current: PTerm;
begin
  index := HashFunction(Name);
  current := Dict.Terms[index];
  
  while current <> nil do
  begin
    if current^.Name = Name then
    begin
      FindTerm := current;
      Exit;
    end;
    current := current^.Next;
  end;
  
  FindTerm := nil;
end;

// Поиск подтермина по имени
function FindSubterm(const Dict: TDictionary; const Name: string): PSubterm;
var
  index: Integer;
  current: PSubterm;
begin
  index := HashFunction(Name);
  current := Dict.Subterms[index];
  
  while current <> nil do
  begin
    if current^.Name = Name then
    begin
      FindSubterm := current;
      Exit;
    end;
    current := current^.Next;
  end;
  
  FindSubterm := nil;
end;

// Добавление термина
procedure AddTerm(var Dict: TDictionary; const Name: string; PageNumber: Integer);
var
  index: Integer;
  newTerm: PTerm;
  term: PTerm;
begin
  // Проверяем, существует ли уже термин с таким именем
  term := FindTerm(Dict, Name);
  if term <> nil then
  begin
    // Если термин уже существует, обновляем номер страницы
    term^.PageNumber := PageNumber;
    Exit;
  end;
  
  // Создаем новый термин
  newTerm := CreateTerm(Name, PageNumber);
  
  // Добавляем термин в хеш-таблицу
  index := HashFunction(Name);
  newTerm^.Next := Dict.Terms[index];
  Dict.Terms[index] := newTerm;
end;

// Добавление подтермина к термину
procedure AddSubtermToTerm(var Dict: TDictionary; const TermName, SubtermName: string; PageNumber: Integer);
var
  term: PTerm;
  subterm: PSubterm;
  index: Integer;
  newSubterm: PSubterm;
begin
  // Находим термин
  term := FindTerm(Dict, TermName);
  if term = nil then
    Exit;
  
  // Проверяем, существует ли уже подтермин с таким именем
  subterm := FindSubterm(Dict, SubtermName);
  
  if subterm = nil then
  begin
    // Создаем новый подтермин
    newSubterm := CreateSubterm(SubtermName, PageNumber);
    
    // Добавляем подтермин в хеш-таблицу
    index := HashFunction(SubtermName);
    newSubterm^.Next := Dict.Subterms[index];
    Dict.Subterms[index] := newSubterm;
    
    // Добавляем имя термина в список родительских терминов подтермина
    AddString(newSubterm^.ParentTerms, TermName);
    
    // Добавляем подтермин в список подтерминов термина
    AddSubtermToList(term^.Subterms, newSubterm);
  end
  else
  begin
    // Если подтермин уже существует, добавляем имя термина в список родительских терминов
    AddString(subterm^.ParentTerms, TermName);
    
    // Добавляем подтермин в список подтерминов термина
    AddSubtermToList(term^.Subterms, subterm);
  end;
end;

// Добавление подтермина к подтермину
procedure AddSubtermToSubterm(var Dict: TDictionary; const ParentSubtermName, SubtermName: string; PageNumber: Integer);
var
  parentSubterm: PSubterm;
  subterm: PSubterm;
  index: Integer;
  newSubterm: PSubterm;
  i: Integer;
begin
  // Находим родительский подтермин
  parentSubterm := FindSubterm(Dict, ParentSubtermName);
  if parentSubterm = nil then
    Exit;
  
  // Проверяем, существует ли уже подтермин с таким именем
  subterm := FindSubterm(Dict, SubtermName);
  
  if subterm = nil then
  begin
    // Создаем новый подтермин
    newSubterm := CreateSubterm(SubtermName, PageNumber);
    
    // Добавляем подтермин в хеш-таблицу
    index := HashFunction(SubtermName);
    newSubterm^.Next := Dict.Subterms[index];
    Dict.Subterms[index] := newSubterm;
    
    // Добавляем имена родительских терминов в список родительских терминов подтермина
    for i := 0 to parentSubterm^.ParentTerms^.Count - 1 do
      AddString(newSubterm^.ParentTerms, parentSubterm^.ParentTerms^.Items[i]);
    
    // Добавляем подтермин в список дочерних подтерминов родительского подтермина
    AddSubtermToList(parentSubterm^.Children, newSubterm);
  end
  else
  begin
    // Если подтермин уже существует, добавляем имена родительских терминов в список родительских терминов
    for i := 0 to parentSubterm^.ParentTerms^.Count - 1 do
      AddString(subterm^.ParentTerms, parentSubterm^.ParentTerms^.Items[i]);
    
    // Добавляем подтермин в список дочерних подтерминов родительского подтермина
    AddSubtermToList(parentSubterm^.Children, subterm);
  end;
end;

// Поиск всех терминов, содержащих указанный подтермин
function FindTermsBySubterm(const Dict: TDictionary; const SubtermName: string): PTermList;
var
  subterm: PSubterm;
  i: Integer;
  term: PTerm;
  result: PTermList;
begin
  result := CreateTermList;
  
  // Находим подтермин
  subterm := FindSubterm(Dict, SubtermName);
  if subterm = nil then
  begin
    FindTermsBySubterm := result;
    Exit;
  end;
  
  // Для каждого родительского термина подтермина
  for i := 0 to subterm^.ParentTerms^.Count - 1 do
  begin
    // Находим термин
    term := FindTerm(Dict, subterm^.ParentTerms^.Items[i]);
    if term <> nil then
      AddTermToList(result, term);
  end;
  
  FindTermsBySubterm := result;
end;

// Поиск всех подтерминов указанного термина
function FindSubtermsByTerm(const Dict: TDictionary; const TermName: string): PSubtermList;
var
  term: PTerm;
  result: PSubtermList;
  i: Integer;
begin
  result := CreateSubtermList;
  
  // Находим термин
  term := FindTerm(Dict, TermName);
  if term = nil then
  begin
    FindSubtermsByTerm := result;
    Exit;
  end;
  
  // Копируем список подтерминов термина
  SetLength(result^.Items, term^.Subterms^.Count);
  result^.Count := term^.Subterms^.Count;
  
  for i := 0 to term^.Subterms^.Count - 1 do
    result^.Items[i] := term^.Subterms^.Items[i];
  
  FindSubtermsByTerm := result;
end;

// Вывод подтермина и его дочерних подтерминов
procedure PrintSubterm(const Subterm: PSubterm; Level: Integer);
var
  i: Integer;
  indent: string;
  children: PSubtermList;
begin
  indent := '';
  for i := 1 to Level do
    indent := indent + '  ';
  
  WriteLn(indent, '- ', Subterm^.Name, ' (стр. ', Subterm^.PageNumber, ')');
  
  // Создаем копию списка дочерних подтерминов
  children := CreateSubtermList;
  SetLength(children^.Items, Subterm^.Children^.Count);
  children^.Count := Subterm^.Children^.Count;
  
  for i := 0 to Subterm^.Children^.Count - 1 do
    children^.Items[i] := Subterm^.Children^.Items[i];
  
  // Сортируем дочерние подтермины по алфавиту
  SortSubtermsByAlphabet(children);
  
  // Выводим дочерние подтермины
  for i := 0 to children^.Count - 1 do
    PrintSubterm(children^.Items[i], Level + 1);
  
  // Освобождаем память, занятую списком
  FreeSubtermList(children);
end;

// Вывод термина и его подтерминов
procedure PrintTerm(const Term: PTerm);
var
  i: Integer;
  subterms: PSubtermList;
begin
  WriteLn('Термин: ', Term^.Name, ' (стр. ', Term^.PageNumber, ')');
  
  // Создаем копию списка подтерминов
  subterms := CreateSubtermList;
  SetLength(subterms^.Items, Term^.Subterms^.Count);
  subterms^.Count := Term^.Subterms^.Count;
  
  for i := 0 to Term^.Subterms^.Count - 1 do
    subterms^.Items[i] := Term^.Subterms^.Items[i];
  
  // Сортируем подтермины по алфавиту
  SortSubtermsByAlphabet(subterms);
  
  // Выводим подтермины
  for i := 0 to subterms^.Count - 1 do
    PrintSubterm(subterms^.Items[i], 1);
  
  // Освобождаем память, занятую списком
  FreeSubtermList(subterms);
  
  WriteLn;
end;

// Вывод всего словаря
procedure PrintDictionary(const Dict: TDictionary; SortByPage: Boolean);
var
  i: Integer;
  terms: PTermList;
  current: PTerm;
begin
  WriteLn('Словарь языков программирования:');
  WriteLn('==============================');
  
  // Создаем список всех терминов
  terms := CreateTermList;
  
  for i := 0 to TABLE_SIZE - 1 do
  begin
    current := Dict.Terms[i];
    while current <> nil do
    begin
      AddTermToList(terms, current);
      current := current^.Next;
    end;
  end;
  
  // Сортируем термины
  if SortByPage then
    SortTermsByPage(terms)
  else
    SortTermsByAlphabet(terms);
  
  // Выводим термины
  for i := 0 to terms^.Count - 1 do
    PrintTerm(terms^.Items[i]);
  
  // Освобождаем память, занятую списком
  FreeTermList(terms);
  
  WriteLn('==============================');
end;

// Заполнение словаря примерами
procedure FillDictionaryWithExamples(var Dict: TDictionary);
begin
  // Добавляем термины (языки программирования)
  AddTerm(Dict, 'Pascal', 10);
  AddTerm(Dict, 'C++', 20);
  AddTerm(Dict, 'Python', 30);
  AddTerm(Dict, 'JavaScript', 40);
  AddTerm(Dict, 'Java', 50);
  
  // Добавляем подтермины для Pascal
  AddSubtermToTerm(Dict, 'Pascal', 'Синтаксис', 11);
  AddSubtermToTerm(Dict, 'Pascal', 'Типы данных', 12);
  AddSubtermToTerm(Dict, 'Pascal', 'Функции', 13);
  AddSubtermToTerm(Dict, 'Pascal', 'Классы', 14);
  AddSubtermToTerm(Dict, 'Pascal', 'Библиотеки', 15);
  
  // Добавляем подтермины для C++
  AddSubtermToTerm(Dict, 'C++', 'Синтаксис', 21);
  AddSubtermToTerm(Dict, 'C++', 'Типы данных', 22);
  AddSubtermToTerm(Dict, 'C++', 'Функции', 23);
  AddSubtermToTerm(Dict, 'C++', 'Классы', 24);
  AddSubtermToTerm(Dict, 'C++', 'Библиотеки', 25);
  
  // Добавляем подтермины для Python
  AddSubtermToTerm(Dict, 'Python', 'Синтаксис', 31);
  AddSubtermToTerm(Dict, 'Python', 'Типы данных', 32);
  AddSubtermToTerm(Dict, 'Python', 'Функции', 33);
  AddSubtermToTerm(Dict, 'Python', 'Классы', 34);
  AddSubtermToTerm(Dict, 'Python', 'Библиотеки', 35);
  
  // Добавляем подтермины для JavaScript
  AddSubtermToTerm(Dict, 'JavaScript', 'Синтаксис', 41);
  AddSubtermToTerm(Dict, 'JavaScript', 'Типы данных', 42);
  AddSubtermToTerm(Dict, 'JavaScript', 'Функции', 43);
  AddSubtermToTerm(Dict, 'JavaScript', 'Классы', 44);
  AddSubtermToTerm(Dict, 'JavaScript', 'Библиотеки', 45);
  
  // Добавляем подтермины для Java
  AddSubtermToTerm(Dict, 'Java', 'Синтаксис', 51);
  AddSubtermToTerm(Dict, 'Java', 'Типы данных', 52);
  AddSubtermToTerm(Dict, 'Java', 'Функции', 53);
  AddSubtermToTerm(Dict, 'Java', 'Классы', 54);
  AddSubtermToTerm(Dict, 'Java', 'Библиотеки', 55);
  
  // Добавляем подтермины к подтерминам (третий уровень вложенности)
  
  // Для Pascal
  AddSubtermToSubterm(Dict, 'Типы данных', 'Целочисленные', 121);
  AddSubtermToSubterm(Dict, 'Типы данных', 'С плавающей точкой', 122);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Строковые', 123);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Логические', 124);
  
  // Для C++
  AddSubtermToSubterm(Dict, 'Типы данных', 'Целочисленные', 221);
  AddSubtermToSubterm(Dict, 'Типы данных', 'С плавающей точкой', 222);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Строковые', 223);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Логические', 224);
  
  // Для Python
  AddSubtermToSubterm(Dict, 'Типы данных', 'Целочисленные', 321);
  AddSubtermToSubterm(Dict, 'Типы данных', 'С плавающей точкой', 322);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Строковые', 323);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Логические', 324);
  
  // Для JavaScript
  AddSubtermToSubterm(Dict, 'Типы данных', 'Целочисленные', 421);
  AddSubtermToSubterm(Dict, 'Типы данных', 'С плавающей точкой', 422);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Строковые', 423);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Логические', 424);
  
  // Для Java
  AddSubtermToSubterm(Dict, 'Типы данных', 'Целочисленные', 521);
  AddSubtermToSubterm(Dict, 'Типы данных', 'С плавающей точкой', 522);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Строковые', 523);
  AddSubtermToSubterm(Dict, 'Типы данных', 'Логические', 524);
end;

end.