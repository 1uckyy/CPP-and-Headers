(*чтение из файла*)
fun fileToListStrings fileName =
    let
        (*string option -> string привод к строке*)
        fun foo(NONE) = ""
        | foo(SOME a) = a;

        val stream = TextIO.openIn(fileName)

        (*рекурсивно получаем массив строк*)
        fun getListStrings(NONE, str) = str
        |   getListStrings(str2, str) = getListStrings(TextIO.inputLine(stream), str @ [foo(str2)])
        val strlist = [foo(TextIO.inputLine(stream))]
        val strlist = getListStrings(TextIO.inputLine(stream), strlist)
        
        val _ = TextIO.closeIn(stream)
    in
        strlist
    end;

val file = fileToListStrings "file.cpp";

(*выделение первого слова в строке*)
fun fw(nil) = nil
|   fw(#" "::t) = nil
|   fw(h::t) = h :: fw(t);
val firstword = implode o fw o explode;

(*третий с конца символ строки*)
fun lc(nil, prev, prevprev) = prevprev
|   lc(h::t, prev, prevprev) = lc(t, h, prev);

(*выделение названия метода*)
fun nm(nil) = nil
|   nm(#"("::t) = nil
|   nm(h::t) = h :: nm(t);
val nameMethod = implode o nm o explode;

(*выделение строки до \n*)
fun sn(nil) = nil
|   sn(#"\n"::t) = nil
|   sn(h::t) = h :: sn(t);
val slashN = implode o sn o explode;

(*выделение типов параметров функции*)
fun tp(nil,0) = nil
|   tp(#"("::t,0) = tp(t,1)
|   tp(#","::t,0) = #"," :: tp(t,1)
|   tp(h::t,0) = tp(t,0)
|   tp(#")"::t,1) = nil
|   tp(#" "::t,1) = tp(t,0)
|   tp(h::t,1) = h :: tp(t,1);
fun typeParameters(str) = 
    let
        val strToArray = explode str
        val charsArray = tp(strToArray, 0)
        val arrayToStr = implode charsArray
    in
        arrayToStr
end;

fun addSemicolon(headerStream, stream, str) =
    let
        val _ = TextIO.output(stream, "\n"^str^"\n")
        val newStr = slashN str
        val _ = TextIO.output(headerStream, "\n"^newStr^";\n")
    in
        1
end;


fun stringToStrOutputContinue(stream, str) =
    let
        val _ = TextIO.output(stream, str)
    in
        1
end;

fun stringToStrOutputContinueMain(stream, str) =
    let
        val _ = TextIO.output(stream, str)
    in
        2
end;

fun stringToStrOutputEnd(stream, str) =
    let
        val _ = TextIO.output(stream, str)
    in
        0
end;

fun stringToHeader(headerStream, stream, str) =
    let
        val atoarray = explode str
        val lastchar = lc(atoarray, #"f", #"f")
    in
        if lastchar = #";" then stringToStrOutputEnd(headerStream, "\n"^str)
        else addSemicolon(headerStream, stream, nameMethod(str)^"("^typeParameters(str)^")")
end;

fun checkLastChar(a) =
    let
        val atoarray = explode a
        val lastchar = lc(atoarray, #"f", #"f")
    in
        if (lastchar = #")" orelse lastchar = #";") andalso (nameMethod(a) <> "int main") then 1
        else if nameMethod(a) = "int main" then 2
        else 0
end;

val stream = TextIO.openOut("add.cpp")
val headerStream = TextIO.openOut("add.h")
val _ = TextIO.output(headerStream, "#ifndef ADD_H\n#define ADD_H\n");
val mainStream = TextIO.openOut("main.cpp")
val _ = TextIO.output(mainStream, "#include \"add.h\"\n");
fun find(nil,0) = nil
|   find(a::b,0) = 
        (case firstword a
        of "#include" => find(b, stringToStrOutputEnd(mainStream, a))
        | "int" => if (checkLastChar(a) = 1) then find(b, stringToHeader(headerStream, stream, a))
        else if (checkLastChar(a) = 2) then find(b, stringToStrOutputContinueMain(mainStream, "\n"^a))
        else find(b, 0)
        | "char" => if (checkLastChar(a) = 1) then find(b, stringToHeader(headerStream, stream, a))
        else find(b, 0)
        | "void" => if (checkLastChar(a) = 1) then find(b, stringToHeader(headerStream, stream, a))
        else find(b, 0)
        | "bool" => if (checkLastChar(a) = 1) then find(b, stringToHeader(headerStream, stream, a))
        else find(b, 0)
        | "double" => if (checkLastChar(a) = 1) then find(b, stringToHeader(headerStream, stream, a))
        else find(b, 0)
        | _ => find(b, 0))
|   find(a::b,1) =
        (case a
        of "}\n" => find(b, stringToStrOutputEnd(stream, a))
        | _ => find(b, stringToStrOutputContinue(stream, a)))
|   find(a::b,2) =
        case a
        of "}\n" => find(b, stringToStrOutputEnd(mainStream, a))
        | _ => find(b, stringToStrOutputContinueMain(mainStream, a));

find (file,0);
val close = TextIO.closeOut(stream);
val _ = TextIO.output(headerStream, "\n#endif\n");
val close = TextIO.closeOut(headerStream);
val close = TextIO.closeOut(mainStream);
