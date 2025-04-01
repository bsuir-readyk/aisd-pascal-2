program Solve;

uses
  SysUtils,
  Types in 'types.pas',
  Utils in 'utils.pas',
  Dictionary in 'dictionary.pas';

// Вывод разделительной линии
procedure PrintSeparator;
begin
  WriteLn;
  WriteLn('===========================================');
  WriteLn;
end;

// Вывод заголовка меню
procedure PrintMenuHeader(const Title: string);
begin
  WriteLn;
  WriteLn('### ', Title, ' ###');
  WriteLn;
end;

// Ожидание нажатия клавиши перед продолжением
procedure WaitForKey;
begin
  WriteLn;
  Write('Нажмите Enter для продолжения...');
  ReadLn;
end;

// Безопасный ввод целого числа с проверкой диапазона
function SafeReadInteger(const Prompt: string; MinValue, MaxValue: Integer): Integer;
var
  s: string;
  code: Integer;
  value: Integer;
  validInput: Boolean;
begin
  repeat
    validInput := False;
    Write(Prompt);
    ReadLn(s);
    
    // Проверка на пустую строку
    if s = '' then
    begin
      WriteLn('Ошибка: Пустой ввод. Пожалуйста, введите число.');
      Continue;
    end;
    
    // Попытка преобразовать строку в число
    Val(s, value, code);
    
    if code <> 0 then
      WriteLn('Ошибка: Введите корректное целое число.')
    else if (value < MinValue) or (value > MaxValue) then
      WriteLn('Ошибка: Число должно быть в диапазоне от ', MinValue, ' до ', MaxValue, '.')
    else
      validInput := True;
      
  until validInput;
  
  SafeReadInteger := value;
end;

// Безопасный ввод строки с проверкой на пустоту
function SafeReadString(const Prompt: string): string;
var
  s: string;
begin
  repeat
    Write(Prompt);
    ReadLn(s);
    
    // Удаляем пробелы в начале и конце строки
    s := Trim(s);
    
    if s = '' then
      WriteLn('Ошибка: Пустой ввод. Пожалуйста, введите текст.');
      
  until s <> '';
  
  SafeReadString := s;
end;

// Демонстрация работы словаря
procedure DemoDictionary;
var
  Dict: TDictionary;
  choice: Integer;
  termName, subtermName: string;
  pageNumber: Integer;
  terms: PTermList;
  subterms: PSubtermList;
  i: Integer;
begin
  // Инициализация словаря
  InitDictionary(Dict);
  
  // Заполнение словаря примерами
  FillDictionaryWithExamples(Dict);
  
  repeat
    PrintMenuHeader('СЛОВАРЬ ЯЗЫКОВ ПРОГРАММИРОВАНИЯ');
    WriteLn('1. Показать словарь (сортировка по алфавиту)');
    WriteLn('2. Показать словарь (сортировка по номеру страницы)');
    WriteLn('3. Добавить термин');
    WriteLn('4. Добавить подтермин к термину');
    WriteLn('5. Добавить подтермин к подтермину');
    WriteLn('6. Найти термин по подтермину');
    WriteLn('7. Найти подтермины термина');
    WriteLn('0. Выход');
    
    // Безопасный ввод выбора пункта меню
    choice := SafeReadInteger('Выберите действие: ', 0, 7);
    
    case choice of
      1: begin
         PrintDictionary(Dict, False);
         WaitForKey;
         end;
      
      2: begin
         PrintDictionary(Dict, True);
         WaitForKey;
         end;
      
      3: begin
        PrintMenuHeader('ДОБАВЛЕНИЕ ТЕРМИНА');
        termName := SafeReadString('Введите название языка программирования: ');
        pageNumber := SafeReadInteger('Введите номер страницы: ', 1, 1000);
        AddTerm(Dict, termName, pageNumber);
        
        PrintSeparator;
        WriteLn('Результат: Термин "', termName, '" успешно добавлен!');
        WaitForKey;
      end;
      
      4: begin
        PrintMenuHeader('ДОБАВЛЕНИЕ ПОДТЕРМИНА К ТЕРМИНУ');
        termName := SafeReadString('Введите название языка программирования: ');
        subtermName := SafeReadString('Введите название подтермина: ');
        pageNumber := SafeReadInteger('Введите номер страницы: ', 1, 1000);
        AddSubtermToTerm(Dict, termName, subtermName, pageNumber);
        
        PrintSeparator;
        WriteLn('Результат: Подтермин "', subtermName, '" успешно добавлен к термину "', termName, '"!');
        WaitForKey;
      end;
      
      5: begin
        PrintMenuHeader('ДОБАВЛЕНИЕ ПОДТЕРМИНА К ПОДТЕРМИНУ');
        termName := SafeReadString('Введите название родительского подтермина: ');
        subtermName := SafeReadString('Введите название подтермина: ');
        pageNumber := SafeReadInteger('Введите номер страницы: ', 1, 1000);
        AddSubtermToSubterm(Dict, termName, subtermName, pageNumber);
        
        PrintSeparator;
        WriteLn('Результат: Подтермин "', subtermName, '" успешно добавлен к подтермину "', termName, '"!');
        WaitForKey;
      end;
      
      6: begin
        PrintMenuHeader('ПОИСК ТЕРМИНА ПО ПОДТЕРМИНУ');
        subtermName := SafeReadString('Введите название подтермина для поиска: ');
        terms := FindTermsBySubterm(Dict, subtermName);
        
        PrintSeparator;
        WriteLn('РЕЗУЛЬТАТЫ ПОИСКА:');
        
        if terms^.Count = 0 then
          WriteLn('Термины не найдены')
        else
        begin
          WriteLn('Найденные термины для подтермина "', subtermName, '":');
          for i := 0 to terms^.Count - 1 do
            WriteLn('- ', terms^.Items[i]^.Name, ' (стр. ', terms^.Items[i]^.PageNumber, ')');
        end;
        
        FreeTermList(terms);
        WaitForKey;
      end;
      
      7: begin
        PrintMenuHeader('ПОИСК ПОДТЕРМИНОВ ТЕРМИНА');
        termName := SafeReadString('Введите название языка программирования для поиска: ');
        subterms := FindSubtermsByTerm(Dict, termName);
        
        PrintSeparator;
        WriteLn('РЕЗУЛЬТАТЫ ПОИСКА:');
        
        if subterms^.Count = 0 then
          WriteLn('Подтермины не найдены')
        else
        begin
          WriteLn('Найденные подтермины для термина "', termName, '":');
          for i := 0 to subterms^.Count - 1 do
            WriteLn('- ', subterms^.Items[i]^.Name, ' (стр. ', subterms^.Items[i]^.PageNumber, ')');
        end;
        
        FreeSubtermList(subterms);
        WaitForKey;
      end;
    end;
  until choice = 0;
  
  // Освобождаем память
  FreeDictionary(Dict);
end;

// Демонстрация эффективности хеширования
procedure DemoHashEfficiency;
var
  Dict: TDictionary;
  i: Integer;
  key, value: string;
  startTime, endTime: TDateTime;
  searchCount, foundCount: Integer;
begin
  PrintMenuHeader('ДЕМОНСТРАЦИЯ ЭФФЕКТИВНОСТИ ХЕШИРОВАНИЯ');
  WriteLn('-------------------------------------');
  
  // Инициализация словаря
  InitDictionary(Dict);
  
  // Заполнение словаря большим количеством записей
  WriteLn('Заполнение словаря...');
  startTime := Now;
  
  for i := 1 to 1000 do
  begin
    key := 'Term' + IntToStr(i);
    AddTerm(Dict, key, i);
    
    key := 'Subterm' + IntToStr(i);
    AddSubtermToTerm(Dict, 'Term' + IntToStr(i mod 100 + 1), key, i);
  end;
  
  endTime := Now;
  WriteLn('Время заполнения: ', FormatDateTime('n:ss:zzz', endTime - startTime));
  
  // Поиск записей
  WriteLn('Поиск записей...');
  startTime := Now;
  searchCount := 0;
  foundCount := 0;
  
  for i := 1 to 1000 do
  begin
    key := 'Term' + IntToStr(Random(2000) + 1); // Ищем как существующие, так и несуществующие ключи
    if FindTerm(Dict, key) <> nil then
      Inc(foundCount);
    Inc(searchCount);
  end;
  
  endTime := Now;
  WriteLn('Время поиска: ', FormatDateTime('n:ss:zzz', endTime - startTime));
  WriteLn('Выполнено поисков: ', searchCount);
  WriteLn('Найдено записей: ', foundCount);
  
  // Освобождение памяти
  FreeDictionary(Dict);
  WriteLn('-------------------------------------');
  
  WaitForKey;
end;

// Обработка ошибок ввода
procedure HandleInputError;
begin
  if IOResult <> 0 then
  begin
    WriteLn('Произошла ошибка ввода. Программа будет перезапущена.');
    WaitForKey;
    Reset(Input);
  end;
end;

var
  choice: Integer;

begin
  Randomize;
  
  repeat
    PrintMenuHeader('ГЛАВНОЕ МЕНЮ');
    WriteLn('1. Словарь языков программирования');
    WriteLn('2. Эффективность хеширования');
    WriteLn('0. Выход');
    
    // Безопасный ввод выбора пункта меню
    choice := SafeReadInteger('Ваш выбор: ', 0, 2);
    
    case choice of
      1: DemoDictionary;
      2: DemoHashEfficiency;
    end;
  until choice = 0;
  
  WriteLn('Программа завершена');
end.
