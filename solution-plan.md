# План решения для словаря языков программирования

## Структура данных

Для реализации словаря с иерархической структурой (термин -> подтермин -> подтермин) и поддержкой требуемых операций, предлагается следующая структура данных:

```pascal
type
  // Указатель на узел подтермина
  PSubterm = ^TSubterm;
  
  // Узел подтермина
  TSubterm = record
    Name: string;           // Название подтермина
    PageNumber: Integer;    // Номер страницы
    ParentTerms: TStringList; // Список терминов, к которым относится подтермин
    Children: TList;        // Список дочерних подтерминов
    Next: PSubterm;         // Указатель на следующий подтермин в хеш-таблице
  end;
  
  // Указатель на узел термина
  PTerm = ^TTerm;
  
  // Узел термина
  TTerm = record
    Name: string;           // Название термина
    PageNumber: Integer;    // Номер страницы
    Subterms: TList;        // Список подтерминов
    Next: PTerm;            // Указатель на следующий термин в хеш-таблице
  end;
  
  // Хеш-таблица для терминов
  TTermHashTable = array[0..TABLE_SIZE-1] of PTerm;
  
  // Хеш-таблица для подтерминов
  TSubtermHashTable = array[0..TABLE_SIZE-1] of PSubterm;
  
  // Словарь
  TDictionary = record
    Terms: TTermHashTable;        // Хеш-таблица терминов
    Subterms: TSubtermHashTable;  // Хеш-таблица подтерминов
  end;
```

## Основные операции

### 1. Инициализация и освобождение памяти

```pascal
// Инициализация словаря
procedure InitDictionary(var Dict: TDictionary);

// Освобождение памяти, занятой словарем
procedure FreeDictionary(var Dict: TDictionary);
```

### 2. Вставка

```pascal
// Добавление термина
procedure AddTerm(var Dict: TDictionary; const Name: string; PageNumber: Integer);

// Добавление подтермина к термину
procedure AddSubterm(var Dict: TDictionary; const TermName, SubtermName: string; PageNumber: Integer);

// Добавление подтермина к подтермину
procedure AddSubtermToSubterm(var Dict: TDictionary; const ParentSubtermName, SubtermName: string; PageNumber: Integer);
```

### 3. Поиск

```pascal
// Поиск термина по имени
function FindTerm(const Dict: TDictionary; const Name: string): PTerm;

// Поиск подтермина по имени
function FindSubterm(const Dict: TDictionary; const Name: string): PSubterm;

// Поиск всех терминов, содержащих указанный подтермин
function FindTermsBySubterm(const Dict: TDictionary; const SubtermName: string): TList;

// Поиск всех подтерминов указанного термина
function FindSubtermsByTerm(const Dict: TDictionary; const TermName: string): TList;
```

### 4. Удаление

```pascal
// Удаление термина
procedure DeleteTerm(var Dict: TDictionary; const Name: string);

// Удаление подтермина
procedure DeleteSubterm(var Dict: TDictionary; const Name: string);
```

### 5. Сортировка и вывод

```pascal
// Сортировка терминов по алфавиту
procedure SortTermsByAlphabet(var Terms: TList);

// Сортировка терминов по номеру страницы
procedure SortTermsByPage(var Terms: TList);

// Сортировка подтерминов по алфавиту
procedure SortSubtermsByAlphabet(var Subterms: TList);

// Сортировка подтерминов по номеру страницы
procedure SortSubtermsByPage(var Subterms: TList);

// Вывод всего словаря
procedure PrintDictionary(const Dict: TDictionary);

// Вывод термина и его подтерминов
procedure PrintTerm(const Term: PTerm);

// Вывод подтермина и его дочерних подтерминов
procedure PrintSubterm(const Subterm: PSubterm);
```

## Пример использования

Для демонстрации работы словаря будет создан пример с терминами и подтерминами из области языков программирования:

1. Термины: "Pascal", "C++", "Python", "JavaScript", "Java"
2. Подтермины для каждого языка: "Синтаксис", "Типы данных", "Функции", "Классы", "Библиотеки"
3. Подтермины для подтерминов: например, для "Типы данных" могут быть "Целочисленные", "С плавающей точкой", "Строковые", "Логические"

## Пользовательский интерфейс

Будет создан консольный интерфейс с меню, позволяющий:

1. Добавлять термины и подтермины
2. Искать термины и подтермины
3. Удалять термины и подтермины
4. Выводить словарь с различными вариантами сортировки
5. Демонстрировать эффективность хеширования

## Особенности реализации

1. Для хранения списков терминов и подтерминов будут использоваться динамические массивы (TList)
2. Для связи подтерминов с терминами будет использоваться список строк (TStringList)
3. Для хеширования будет использоваться простая хеш-функция, аналогичная той, что была в исходном решении
4. Для сортировки будут реализованы функции сравнения для различных критериев (алфавит, номер страницы)