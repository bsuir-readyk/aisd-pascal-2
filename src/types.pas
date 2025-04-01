unit Types;

interface

const
  // Размер хеш-таблицы
  TABLE_SIZE = 10;

type
  // Указатель на узел подтермина
  PSubterm = ^TSubterm;
  
  // Список указателей на подтермины
  PSubtermList = ^TSubtermList;
  TSubtermList = record
    Items: array of PSubterm;
    Count: Integer;
  end;
  
  // Список строк (для хранения имен родительских терминов)
  PStringList = ^TStringList;
  TStringList = record
    Items: array of string;
    Count: Integer;
  end;
  
  // Узел подтермина
  TSubterm = record
    Name: string;           // Название подтермина
    PageNumber: Integer;    // Номер страницы
    ParentTerms: PStringList; // Список терминов, к которым относится подтермин
    Children: PSubtermList;   // Список дочерних подтерминов
    Next: PSubterm;         // Указатель на следующий подтермин в хеш-таблице
  end;
  
  // Указатель на узел термина
  PTerm = ^TTerm;
  
  // Список указателей на термины
  PTermList = ^TTermList;
  TTermList = record
    Items: array of PTerm;
    Count: Integer;
  end;
  
  // Узел термина
  TTerm = record
    Name: string;           // Название термина
    PageNumber: Integer;    // Номер страницы
    Subterms: PSubtermList; // Список подтерминов
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

implementation

end.