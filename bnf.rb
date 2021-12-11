require './rdparse'
require './nodes'

class PoliteParser

  def initialize

    @PleaseParser = Parser.new("PleaseParser") do
      token(/\s+/)
      token(/~.*~/m)
      token(/~.*/)
      token(/Dear computer,/){|m| m }
      token(/please remember the following template for objects of the type/){|m| m }
      token(/please remember the following instructions named/) {|m| m }
      token(/please repeat the following counting from/) {|m| m }
      token(/please create an object using the template/){|m| m }
      token(/please follow the instructions named/){|m| m }
      token(/please repeat the following for each/){|m| m }
      token(/please remove the element at index/){|m| m }
      token(/it has the following instructions:/){|m| m }
      token(/please consider the following, is/){|m| m }
      token(/please repeat the following until/){|m| m }
      token(/please create the variable named/) {|m| m }
      token(/please access the item at index/) {|m| m }
      token(/it has the following variables:/){|m| m }
      token(/please create the list named/) {|m| m }
      token(/please repeat the following/) {|m| m }
      token(/please write the following:/) {|m| m }
      token(/please change the value of/) {|m| m }
      token(/and remember the result as/){|m| m }
      token(/containing the result of/) {|m| m }
      token(/please return nothing/){|m| m }
      token(/times counting with/){|m| m }
      token(/which inherits from/){|m| m }
      token(/to the result of/) {|m| m }
      token(/please remove/){|m| m }
      token(/containing/) {|m| m }
      token(/please don\'t/) {|m| m }
      token(/please return/) {|m| m }
      token(/please write/){|m| m }
      token(/please stop/) {|m| m }
      token(/please add/){|m| m }
      token(/at index/){|m| m }
      token(/"[^"]*"/){|m| m }
      token(/thank you/) {|m| m }
      token(/Sincerely,/){|m| m }
      token(/times\./) {|m| m }
      token(/adding/){|m| m }
      token(/otherwise, is/){|m| m }
      token(/otherwise/){|m| m }
      token(/subtracting/){|m| m }
      token(/multiplying/){|m| m }
      token(/dividing/){|m| m }
      token(/equal to/){|m| m }
      token(/greater than/){|m| m }
      token(/less than/){|m| m }
      token(/up to/){|m| m }
      token(/with/) {|m| m }
      token(/from/) {|m|m}
      token(/then/) {|m|m}
      token(/to/) {|m| m }
      token(/in/){|m| m }
      token(/'s/){|m| m }
      token(/\?/) {|m| m }
      token(/-?\d+\.\d+/){|m| m.to_f}
      token(/-?\d+/){|m| m.to_i}
      token(/\w+/) {|m| m }
      token(/\./) {|m| m }
      token(/./) {|m| m}

#please change the value of <identifier> by <variable_expr>.
#Parse error. expected: '', found 'thank you' (Parser::ParseError)



      start :program do
        match(:main_func) {|main_func| Program_Node.new(main_func)}
        match(:class_declarations, :func_declarations, :main_func) { | class_declarations, func_declarations, main_func |
              Program_With_Classes_And_Functions_Node.new(class_declarations, func_declarations, main_func) }
        match(:class_declarations, :main_func) { | class_declarations, main_func |
              Program_With_Classes_Node.new(class_declarations, main_func) }
        match(:func_declarations, :main_func) { | func_declarations, main_func |
              Program_With_Functions_Node.new(func_declarations, main_func) }
      end

      rule :class_declarations do
        match(:class_declarations,:class_declaration)
        match(:class_declaration)
      end

      rule :class_declaration do
        match('please remember the following template for objects of the type', :identifier, 'which inherits from', :identifier, '.', :class_content, 'thank you') {
              | _, class_id, _, inherit_id, _, content, _ | Class_Inheritance_Decl_Node.new(class_id, inherit_id, content) }
        match('please remember the following template for objects of the type', :identifier, '.', :class_content, 'thank you') {
              | _, class_id, _, content,_ | Class_Decl_Node.new(class_id, content) }
      end

      rule :class_content do
        match('it has the following variables:', :class_variable_declarations, 'it has the following instructions:', :class_func_declarations) {
              | _, variables, _, functions | Class_Var_Func_Content_Node.new(variables, functions) }
        match('it has the following variables:', :class_variable_declarations) {
              | _, variables| Class_Var_Content_Node.new(variables) }
        match('it has the following instructions:', :class_func_declarations) {
              | _, functions | Class_Func_Content_Node.new(functions) }
      end

      rule :class_variable_declarations do
        match(:class_variable_declarations, ',', :class_variable_declaration) {
              | declarations, _, declaration | Identifiers_Node.new(declarations, declaration) }
        match(:class_variable_declaration)
      end

      rule :class_func_declarations do
        match(:class_func_declarations, :class_func_declaration) {
             | declarations, declaration | Class_Function_Declarations_Node.new(declarations, declaration) }
        match(:class_func_declaration)
      end

      rule :class_func_declaration do
        match('please remember the following instructions named', :identifier, 'with', :param_identifiers, '.', :instructions, :return_statement, 'thank you') {
              | _, id, _, parameters, _, instructions, return_statement, _ | Class_Function_Param_Declaration_Node.new(id, parameters, instructions, return_statement) }
        match('please remember the following instructions named', :identifier, '.', :instructions, :return_statement, 'thank you') {
              | _, id, _, instructions, return_statement, _ | Class_Function_Declaration_Node.new(id, instructions, return_statement) }
      end

      rule :class_variable_declaration do
        match(/\w+/) { | id | Identifier_Node.new(id) }
      end

      rule :func_declarations do
        match(:func_declarations,:func_declaration)
        match(:func_declaration)
      end

      rule :func_declaration do
        match('please remember the following instructions named', :identifier, 'with', :param_identifiers, '.', :instructions, :return_statement, 'thank you') {
              | _, id, _, parameters, _, instructions, return_statement, _ | Function_Param_Declaration_Node.new(id, parameters, instructions, return_statement) }
        match('please remember the following instructions named', :identifier, '.', :instructions, :return_statement, 'thank you') {
              | _, id, _, instructions, return_statement, _ | Function_Declaration_Node.new(id, instructions, return_statement) }
      end

      rule :func_call do
        match('please follow the instructions named', :identifier, 'in', :accessor, 'with', :parameters, 'and remember the result as', :identifier, '.') {
              | _, func_id, _, obj_id, _, parameters, _, variable, _ | Class_Func_Call_Var_Decl_Param_Node.new(func_id, obj_id, parameters, variable) }
        match('please follow the instructions named', :identifier, 'in', :accessor, 'and remember the result as', :identifier, '.') {
              | _, func_id, _, obj_id, _, variable, _ | Class_Func_Call_Var_Decl_Node.new(func_id, obj_id, variable) }
        match('please follow the instructions named', :identifier, 'in', :accessor, 'with', :parameters, '.') {
              | _, func_id, _, obj_id, _, parameters, _ | Class_Func_Call_Param_Node.new(func_id, obj_id, parameters) }
        match('please follow the instructions named', :identifier, 'in', :accessor, '.') {
              | _, func_id, _, obj_id, _ | Class_Func_Call_Node.new(func_id, obj_id) }
        match('please follow the instructions named', :identifier, 'with', :parameters, 'and remember the result as', :identifier, '.') {
              | _, func_id, _, parameters, _, var_id, _ | Func_Call_Var_Decl_Param_Node.new(func_id, parameters, var_id) }
        match('please follow the instructions named', :identifier, 'and remember the result as', :identifier, '.') {
              | _, id, _, variable, _ | Func_Call_Var_Decl_Node.new(id, variable) }
        match('please follow the instructions named', :identifier, 'with', :parameters, '.') {
              | _, id, _, parameters, _ | Func_Call_Param_Node.new(id, parameters) }
        match('please follow the instructions named', :identifier, '.') {
              | _, id, _ | Function_Call_Node.new(id) }
      end

      rule :return_statement do
        match('please return nothing')
        match('please return', :identifier) {
             | _, variable | Return_Node.new(variable) }
      end

      rule :param_identifiers do
        match(:param_identifiers, ',', :param_identifier) {
             | ids, _, id | Identifiers_Node.new(ids, id) }
        match(:param_identifier)
      end

      rule :param_identifier do
        match(/\w+/) {|id | Identifier_Node.new(id) }
      end

      rule :parameters do
        match(:parameters, ',', :parameter) {
             | parameters, _, parameter | Parameters_Node.new(parameters, parameter) }
        match(:parameter) { | parameter | Parameter_Node.new(parameter) }
      end

      rule :parameter do
        match(:variable)
        match(:accessor)
      end

      rule :main_func do
        match('Dear computer,', :instructions, 'Sincerely,', :identifier) {
             | _, instructions, _, _ | Main_Func_Node.new(instructions)}
      end

      rule :instructions do
        match(:instructions, :instruction) {
             | instructions, instruction | Instructions_Node.new(instruction, instructions) }
        match(:instruction)
      end

      rule :instruction do
        match(:class_object_initializer)
        match(:variable_declaration)
        match(:variable_assignment)
        match(:func_call)
        match(:control_statement)
        match(:print_statement)
        match(:container_management)
      end

      rule :class_object_initializer do
        match('please create an object using the template', :identifier, 'named', :identifier, 'with', :parameters, '.') {
             |_, class_id, _, obj_id, _, variables, _ | Class_Object_Initializer_Node.new(class_id, obj_id, variables) }
      end


      rule :variable_declaration do
        match('please create the list named', :identifier, 'containing', :list, '.') {
             | _, id, _, data, _ | Variable_Declaration_Node.new(id, data) }
        match('please create the variable named', :identifier, 'containing the result of', :expr, '.') {
             | _, id, _, data, _ | Variable_Declaration_Node.new(id, data) }
        match('please create the variable named', :identifier, 'containing', :variable, '.') {
             | _, id, _, data, _ | Variable_Declaration_Node.new(id, data) }
      end

      rule :variable_assignment do
        match('please change the value of', :identifier, 'to', :variable, '.') {
             | _, id, _, data, _ | Variable_Assignment_Node.new(id, data) }
        match('please change the value of', :identifier, 'to the result of', :expr, '.') {
             | _, id, _, data, _ | Variable_Assignment_Node.new(id, data) }
      end

      rule :control_statement do
        match(:for_statement)
        match(:while_statement)
        match(:if_statement)
        match(:break_statement)
      end

      rule :while_statement do
        match('please repeat the following until', :condition, '.', :instructions, 'thank you') {
              | _, condition, _ , instructions, _ | While_Node.new(condition, instructions) }
      end

      rule :for_statement do
        match('please repeat the following for each', :identifier, 'in', :identifier, '.', :instructions, 'thank you') {
             | _ , temp_var, _, container, _, instructions, _ | For_Each_Node.new(temp_var, container, instructions) }
        match('please repeat the following', :data, 'times.', :instructions, 'thank you') {
             | _, int, _, instructions, _ | For_Upto_Node.new(int, instructions) }
        match('please repeat the following', :data, 'times counting with', :data, '.', :instructions, 'thank you') {
             | _, int, _, variable, _ , instructions, _ | For_Upto_Variable_Node.new(int, variable, instructions) }
        match('please repeat the following counting from', :data, 'up to', :data, 'with', :data, '.', :instructions, 'thank you') {
             | _, start, _,stop, _, variable, _ , instructions, _ | For_Range_Variable_Node.new(start, stop, variable, instructions) }
      end

      rule :break_statement do
        match('please don\'t') { | _ | Break_Node.new()}
        match('please stop') { | _ | Break_Node.new()}
      end

      rule :if_statement do
        match('please consider the following, is', :condition, '?', 'then', :instructions, 'thank you') {
             |_, condition, _, _, instructions, _ | If_Node.new(condition, instructions) }
        match('please consider the following, is', :condition, '?', 'then', :instructions, 'otherwise', :instructions, 'thank you'){
             |_, condition, _, _, instructions_if, _, instructions_else, _ | If_Else_Node.new(condition, instructions_if, instructions_else) }
        match('please consider the following, is', :condition, '?', 'then', :instructions, :otherwise_statements, 'thank you') {
             |_, condition, _, _, instructions, otherwise_statements, _ | If_Elif_Node.new(condition, instructions, otherwise_statements) }
        match('please consider the following, is', :condition, '?', 'then', :instructions, :otherwise_statements, 'otherwise', :instructions, 'thank you') {
             |_, condition, _, _, instructions_if, otherwise_statements, _, instructions_else, _ | If_Elif_Else_Node.new(condition, instructions_if, otherwise_statements, instructions_else) }
      end

      rule :otherwise_statements do
        match(:otherwise_statements, :otherwise_statement) {
             | statements, statement | Otherwise_Statements_Node.new(statements, statement) }
        match(:otherwise_statement)
      end

      rule :otherwise_statement do
        match('otherwise, is', :condition, '?', 'then', :instructions) {
             | _, condition, _, _, instructions | Otherwise_Statement_Node.new(condition, instructions) }
      end

      rule :condition do
        match(:bool_condition)
        match(:or_condition)
        match(:and_condition)
      end

      rule :or_condition do
        match(:bool_condition, 'or is', :bool_condition) {
             | condition_a , _ , condition_b | Or_Node.new(condition_a, condition_b) }
      end

      rule :and_condition do
        match(:bool_condition, 'and is', :bool_condition) {
             | condition_a , _ , condition_b | And_Node.new(condition_a, condition_b) }
      end

      rule :bool_condition do
        match(:factor, 'greater than', :factor) {
             | variable_a , _ , variable_b | Greater_Node.new(variable_a, variable_b) }
        match(:factor, 'less than', :factor) {
             | variable_a , _ , variable_b | Lesser_Node.new(variable_a, variable_b) }
        match(:factor, 'equal to', :factor) {
             | variable_a , _ , variable_b | Equals_Node.new(variable_a, variable_b) }
        match('not', :factor) {
             | _ , variable | Not_Node.new(variable) }
        match(:bool)
      end

      rule :print_statement do
        match('please write the following:', :output , '.') {
             | _, variable,_ | Print_Node.new(variable) }
        match('please write the following:', :accessor, '.') {
             | _, variable, _ | Print_Node.new(variable) }
        match('please write', :identifier , '\'s', :identifier , '.') {
             | _, object, _ , variable, _ | Class_Print_Node.new(object, variable) }
      end

      rule :container_management do
        match(:list_insertion)
        match(:list_item_removal)
        match(:list_index_removal)
        match(:list_access)
        match(:list_index_insertion)
      end

      rule :list_index_insertion do
        match('please add', :accessor, 'to', :identifier, 'at index', :data, '.') {
             | _, variable, _, id, _, index, _ | List_Index_Insertion_Node.new(variable, id, index) }
        match('please add', :variable, 'to', :identifier, 'at index', :data, '.') {
             | _, variable, _, id, _, index, _ | List_Index_Insertion_Node.new(variable, id, index) }
      end

      rule :list_insertion do
        match('please add', :accessor, 'to', :identifier, '.') {
             | _, variable, _, id, _ | List_Insertion_Node.new(variable, id) }
        match('please add', :variable, 'to', :identifier, '.') {
             | _, variable, _, id, _ | List_Insertion_Node.new(variable, id) }
      end

      rule :list_index_removal do
        match('please remove the element at index', :data, 'from', :identifier, '.'){
             | _, index, _, id, _ | List_Index_Removal_Node.new(index, id) }
      end

      rule :list_item_removal do
        match('please remove', :accessor, 'from', :identifier, '.') {
             | _, variable, _, id, _ | List_Item_Removal_Node.new(variable, id) }
        match('please remove', :variable, 'from', :identifier, '.') {
             | _, variable, _, id, _ | List_Item_Removal_Node.new(variable, id) }
      end

      rule :list_access do
        match('please access the item at index', :data, 'in', :identifier, '.') {
             | _, index, _, id, _ | List_Access_Node.new(index, id) }
      end

      rule :expr do
        match('adding', :term, 'to' ,:term) {
             |  _ ,term_a, _, term_b | Addition_Node.new(term_a, term_b) }
        match('subtracting', :term, 'from',:term) {
             |  _ ,term_a, _, term_b | Subtraction_Node.new(term_a, term_b) }
        match(:term) { | term | Expression_Node.new(term) }
      end

      rule :term do
        match('multiplying', :factor, 'with', :factor) {
             |  _ ,factor_a, _, factor_b | Multiplication_Node.new(factor_a, factor_b) }
        match('dividing', :factor,'with', :factor) {
             |  _ ,factor_a, _, factor_b | Division_Node.new(factor_a, factor_b) }
        match(:factor)  { | factor | Factor_Node.new(factor) }
      end

      rule :factor do
        match(:accessor)
        match(:variable)
      end

      rule :accessor do
        match(/\w+/) { | accessor | Accessor_Node.new(accessor) }
      end

      rule :list do
        match(:elements) { | variables| List_Node.new(variables) }
      end

      rule :elements do
        match(:elements, ',', :element){
             | variables, _, variable | Variables_Node.new(variables, variable) }
        match(:element)
      end

      rule :element do
        match(Float) { | result | Float_Node.new(result) }
        match(Integer) { | result | Integer_Node.new(result) }
        match(/".*"/) { | result | String_Node.new(result) }
        match(:identifier) { | var | Accessor_Node.new(var) }
      end

      rule :variables do
        match(:variables, ',', :variable) {
             | variables, _, variable | Variables_Node.new(variables, variable) }
        match(:variable)
      end

      rule :variable do
        match(Float) { | result | Float_Node.new(result) }
        match(Integer) { | result | Integer_Node.new(result) }
        match(/".*"/) { | result | String_Node.new(result) }
      end

      rule :bool do
        match(true) { | bool | Bool_Node.new(bool) }
        match(false) { | bool | Bool_Node.new(bool) }
      end

      rule :container do
        match(:list)
      end


      rule :data do
        match(Integer) { | data | data }
        match(String) { | data | data }
      end

      rule :output do
        match(/".*"/)
      end

      rule :identifier do
        match(/\w+/) { | id | id }
      end
    end
  end


  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end

  def run(file_string)
    print "[PoliteParser]: "
    str = file_string
    root_node = @PleaseParser.parse str
    puts "#{root_node.eval()}"
    #run <-------------------
  end

  def test(str)
    return @PleaseParser.parse str
  end

  def log(state = false)
    if state
      @PleaseParser.logger.level = Logger::DEBUG
    else
      @PleaseParser.logger.level = Logger::UNKNOWN
    end
  end
end
file_name = ARGV[0].to_s
file_string = open(file_name) { |f| f.read }
PoliteParser.new.run(file_string)
