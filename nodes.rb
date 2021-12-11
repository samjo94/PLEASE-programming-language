@@variables = []
@@variables[0] = {}
@@functions = {}
@@break_bool = false
@@classes = {}

#This function is needed because ruby is a terrible language that has no
#in-built function for doing a deepcopy of a hash
def deep_copy(o)
  Marshal.load(Marshal.dump(o))
end

#Program_Node created as root node if the code received does not contain
#any classes nor functions.
#Parameters:
#main_func is a Main_Func_Node
class Program_Node
  def initialize(main_func)
    @main_func = main_func
  end

  def eval()
    @main_func.eval()
  end
end

#Program_Node created as root node if the code received does contains
#classes and functions.
#Parameters:
#class_declarations contains one of the two types of class declaration nodes
#func_declarations contains one of the two types of functon declaration nodes
#main_func is a Main_Func_Node
class Program_With_Classes_And_Functions_Node
  def initialize(class_declarations, func_declarations, main_func)
    @class_declarations = class_declarations
    @func_declarations = func_declarations
    @main_func = main_func
  end

  def eval()
    @class_declarations.eval()
    @func_declarations.eval()
    @main_func.eval()
  end
end

#Program_Node created as root node if the code received
#contains class declarations but no function declarations
#Parameters:
#class_declarations contains one of the two types of class declaration nodes
#main_func is a Main_Func_Node
class Program_With_Classes_Node
  def initialize(class_declarations, main_func)
    @class_declarations = class_declarations
    @main_func = main_func
  end

  def eval()
    @class_declarations.eval()
    @main_func.eval()
  end
end

#Program_Node created as root node if the code received
#contains function declarations but no class declarations
#Parameters:
#func_declarations contains one of the two types of functon declaration nodes
#main_func is a Main_Func_Node
class Program_With_Functions_Node
  def initialize(func_declarations, main_func)
    @func_declarations = func_declarations
    @main_func = main_func
  end

  def eval()
    @func_declarations.eval()
    @main_func.eval()
  end
end

#Node created when a class is declared
#ID is the name of the class
#Content is the class content, such as variable or function declarations
#in the form of one of three types of class_content nodes
class Class_Decl_Node
  def initialize(id, content)
    @id = id
    @content = content.eval
    @@classes[@id] = @content
  end

  def eval()
  end
end

#This node created when a class is declared that inherits from another class.
#The class that is ineherited froms contents is copied to the new class's hash
#Parameters:
#id is the name of the class
#inherit_id is the name of the class that the class inherits froms
#content is the class content, such as variable or function declarations
#in the form of one of three types of class_content nodes
class Class_Inheritance_Decl_Node
  def initialize(id, inherit_id, content)
    @id = id
    @inherit_id = inherit_id
    @temp = deep_copy(@@classes[@inherit_id])
    @content = content.eval
    @@classes[@id] = {}
    @@classes[@id].merge!(@@classes[@inherit_id])
    @@classes[@id]['variables'].concat(@content['variables'])
    @@classes[@id]['variables'].uniq!()
    @@classes[@id]['functions'].merge!(@content['functions'])
    @@classes[@inherit_id] = @temp
  end

  def eval()
  end
end

#This node is created when a class is declared that has both variables and functions
#Parameters:
#variables, which are the names of variables belonging to the class in the form
#of a parameters_node
#functions are the functions belonging to the class in the form of an class_func_declarations node
class Class_Var_Func_Content_Node
  def initialize(variables, functions)
    @variables = variables
    @functions = functions.eval
    @class_contents = {}
    @class_contents["variables"] = @variables.eval()
    @class_contents["functions"] = {}

    i = 0
    loop do
      @class_contents["functions"][@functions[i]] = @functions[i+1]
      i += 2
      if(i == @functions.size)
        break
      end
    end

  end

  def eval()
    return @class_contents
  end
end

#Class Node which contains member variables but no member functions
#Parameters:
#variables, which are the names of variables belonging to the class in the form
#of a parameters_node
class Class_Var_Content_Node
  def initialize(variables)
    @variables = variables
    @class_contents = {}
    @class_contents["variables"] = @variables.eval()
    @class_contents["functions"] = {}
  end

  def eval()
    return @class_contents
  end
end

#Class Node which contains member functions but no member variables
#Parameters:
#functions, which are the names of functions belonging to the class
class Class_Func_Content_Node
  def initialize(functions)
    @functions = functions.eval
    @class_contents = {}
    @class_contents["variables"] = {}
    @class_contents["functions"] = {}

    i = 0
    loop do
      @class_contents["functions"][@functions[i]] = @functions[i+1]
      i += 2
      if(i == @functions.size)
        break
      end
    end

  end

  def eval()
    return @class_contents
  end
end

#Class Node which works as a constructor when a class object is created
#Parameters:
#class_id contains the name of the class
#object_id contains the name of the object to be created
#variables are Parameter_Nodes that transfer the values given in the
#creation of a class object to the objects class variables
class Class_Object_Initializer_Node
  def initialize(class_id, object_id, variables)
    @class_id = class_id
    @object_id = object_id
    @variables = variables.eval()
    @class_object = {}
    @class_object['#class'] = @class_id
  end

  def eval()

    i = 0
    @@classes[@class_id]['variables'].each do | var |
      @class_object[var] = @variables[i].eval()
      i = i+1
    end

    @@variables.last[@object_id] = @class_object
  end
end

#The main_function node contains the main_function
#Parameters:
#main_func is an instructions node containg all instructions in the main function
class Main_Func_Node
  def initialize(main_func)
    @main_func = main_func
  end

  def eval()
    @main_func.eval()
  end
end

#This nodes contains the function declarations of a class in the form of one
# class_function_declarations node and one class_function_declaration node
#Parameters:
#declarations is a Class_Function_Declarations_Node
#declaration is a Class_Function_Declaration_Node
class Class_Function_Declarations_Node
  def initialize(declarations, declaration)
    @declarations = declarations
    @declaration = declaration
  end

  def eval()
    return_list = Array.new()
    return_list.append(@declarations.eval())
    return_list.append(@declaration.eval())
    return_list.flatten!(1)
    return return_list
  end
end

#Node that contains a function declaration within a class
#Parameters:
#id, the name of the function
#instructions, an Instructions_Node
#return_statement which is what the function returns
class Class_Function_Declaration_Node
  def initialize(id, instructions, return_statement)
    @id = id
    @instructions = instructions
    @return_statement = return_statement
    @function = {}
    @function["instructions"] = @instructions
    @function["return_statement"] = @return_statement
  end

  def eval()
    return_list = [@id, @function]
    return return_list
  end
end

#Node that contains a function declaration
#Parameters:
#id, the name of the function
#instructions, an Instructions_Node
#return_statement which is what the function returns
class Function_Declaration_Node
  def initialize(id, instructions, return_statement)
    @id = id
    @instructions = instructions
    @return_statement = return_statement
    @@functions[@id] = {}
    @@functions[@id]["instructions"] = @instructions
    @@functions[@id]["return_statement"] = @return_statement
  end

  def eval()
  end
end

#Node that contains a function declaration with parameters
#Parameters:
#id, the name of the function
#parameters_names, the names of all parameters
#instructions, an Instructions_Node
#return_statement which is what the function returns
class Function_Param_Declaration_Node
  def initialize(id, parameter_names, instructions, return_statement)
    @id = id
    @parameter_names = parameter_names
    @instructions = instructions
    @return_statement = return_statement
    @@functions[@id] = {}
    @@functions[@id]["instructions"] = @instructions
    @@functions[@id]["parameter_names"] = @parameter_names
    @@functions[@id]["return_statement"] = @return_statement
  end

  def eval()
  end
end

#Node containing a function declaration within a class with parameters
#Parameters:
#id, the name of the function
#parameters_names, the names of all parameters
#instructions, an Instructions_Node
#return_statement which is what the function returns
class Class_Function_Param_Declaration_Node
 def initialize(id, parameter_names, instructions, return_statement)
   @id = id
   @parameter_names = parameter_names
   @instructions = instructions
   @return_statement = return_statement
   @function = {}
   @function["instructions"] = @instructions
   @function["parameter_names"] = @parameter_names
   @function["return_statement"] = @return_statement
 end

 def eval()
   return [@id,@function]
 end
end

#this node handles functions calls to functions that are part of a class
#Parameters:
#func_id is the name of the function being called
#obj_id is the name of the object that the function is being called on
class Class_Func_Call_Node
  def initialize(func_id, obj_id)
    @func_id = func_id
    @obj = obj_id
    @scope = {}
  end

  def eval()
    @obj = @obj.eval

    for var in @obj
      if var[0] != '#class'
        @scope[var[0]] = var[1]
      end
    end

    @@variables.append(@scope)
    @@classes[@obj['#class']]["functions"][@func_id]["instructions"].eval()

    for var in @obj
      if var[0] != '#class'
        @obj[var[0]] = @scope[var[0]]
      end
    end

    @@variables.pop()
  end
end

#this node handles functions calls to functions that are part of a class and
#that takes arguments
#Parameters:
#func_id is the name of the function being called
#obj_id is the name of the object that the function is being called on
#parameters are the arguments the function takes in the form of a parameters_node
class Class_Func_Call_Param_Node
  def initialize(func_id, obj_id, parameters)
    @func_id = func_id
    @obj = obj_id
    @parameters = parameters
    @scope = {}
  end

  def eval()
    @obj = @obj.eval()
    @parameter_list = @parameters.eval()
    @parameter_names = @@classes[@obj['#class']]['functions'][@func_id]["parameter_names"].eval()
    for var in @obj
      if var[0] != '#class'
        @scope[var[0]] = @obj[var[0]]
      end
    end

    i = 0
    @parameter_names.each do |param|
      @scope[param] = @parameter_list[i].eval()
      i = i+1
    end

    @@variables.append(@scope)
    @@classes[@obj['#class']]["functions"][@func_id]["instructions"].eval()

    for var in @obj
      if var[0] != '#class'
        @obj[var[0]] = @scope[var[0]]
      end
    end

    @@variables.pop()
  end
end

#this node handles functions calls to functions that are part of a class
#and returns a value to a varible
#Parameters:
#func_id is the name of the function being called
#obj_id is the name of the object that the function is being called on
#variable, the name of the variable to be defined
class Class_Func_Call_Var_Decl_Node
  def initialize(func_id, obj_id, variable)
    @func_id = func_id
    @obj = obj_id
    @variable = variable
    @scope = {}
  end

  def eval()
    @obj = @obj.eval

    for var in @obj
      if var[0] != '#class'
        @scope[var[0]] = var[1]
      end
    end

    @@variables.append(@scope)
    @@classes[@obj['#class']]["functions"][@func_id]["instructions"].eval()

    for var in @obj
      if var[0] != '#class'
        @obj[var[0]] = @scope[var[0]]
      end
    end

    value = @@classes[@obj['#class']]["functions"][@func_id]["return_statement"].eval()
    @@variables[@@variables.length-2][@variable] = value
    @@variables.pop()
  end
end

#this node handles functions calls to functions that are part of a class,
#has parameters and returns a value to a varible
#Parameters:
#func_id is the name of the function being called
#obj_id is the name of the object that the function is being called on
#parameters are the arguments the function takes in the form of a parameters_node
#variable, the name of the variable to be defined
class Class_Func_Call_Var_Decl_Param_Node
  def initialize(func_id, obj_id, parameters, variable)
    @func_id = func_id
    @obj = obj_id
    @parameters = parameters
    @variable = variable
    @scope = {}
  end

  def eval()
    @obj = @obj.eval()
    @parameter_list = @parameters.eval()
    @parameter_names = @@classes[@obj['#class']]['functions'][@func_id]["parameter_names"].eval()

    for var in @obj
      if var[0] != '#class'
        @obj[var[0]] = @scope[var[0]]
      end
    end

    i = 0
    @parameter_names.each do |param|
      @scope[param] = @parameter_list[i].eval()
      i = i+1
    end

    @@variables.append(@scope)
    @@classes[@obj['#class']]["functions"][@func_id]["instructions"].eval()

    for var in @obj
      if var[0] != '#class'
        @obj[var[0]] = @scope[var[0]]
      end
    end

    value = @@classes[@obj['#class']]["functions"][@func_id]["return_statement"].eval()
    @@variables[@@variables.length-2][@variable] = value
    @@variables.pop()
  end
end

#This node handles function calls
#Parameters:
#id is the name of the function being called
class Function_Call_Node
  def initialize(id)
    @id = id
    @scope = {}
  end

  def eval()
    @@variables.append(@scope)
    @@functions[@id]["instructions"].eval()
    @@variables.pop()
    @scope = {}
  end
end

#This node handles function calls where the result of the call will be saved as
#as a variable
#Parameters:
#id is the name of the function being called
#varaible is the name of the varaible the result will be saved as
class Func_Call_Var_Decl_Node
  def initialize(id, variable)
    @id = id
    @variable = variable
    @scope = {}
  end

  def eval()
    @@variables.append(@scope)
    @@functions[@id]["instructions"].eval()
    value = @@functions[@id]["return_statement"].eval()
    @@variables[@@variables.length-2][@variable] = value
    @@variables.pop()
    @@variables
  end
end

#This node handles function calls that takes arguments
#Parameters:
#id is the name of the function being called
#parameters are the arguments to the function in the form of a parameters_node
class Func_Call_Param_Node
  def initialize(id, parameters)
    @id = id
    @parameters = parameters
    @scope = {}
  end

  def eval()
    @parameter_list = @parameters.eval()
    @parameter_names = @@functions[@id]["parameter_names"].eval()

    i = 0
    @parameter_names.each do |param|
      @scope[param] = @parameter_list[i].eval()
      i = i+1
    end

    @@variables.append(@scope)
    @@functions[@id]["instructions"].eval()
    @@variables.pop()
    @scope = {}
  end
end

#This node handles function calls where the result of the call will be saved as
#as a variable and that takes arguments
#Parameters:
#id is the name of the function being called
#variable is the name of the varaible the result will be saved as
#parameters are the arguments to the function in the form of a parameters_node
class Func_Call_Var_Decl_Param_Node
  def initialize(id, parameters, var_id)
    @id = id
    @parameters = parameters
    @var_id = var_id
    @scope = {}
  end

  def eval()
    @parameter_list = @parameters.eval()
    @parameter_names = @@functions[@id]["parameter_names"].eval()

    i = 0
    @parameter_names.each do |param|
      @scope[param] = @parameter_list[i].eval()
      i = i+1
    end

    @@variables.append(@scope)
    @@functions[@id]["instructions"].eval()
    value = @@functions[@id]["return_statement"].eval()
    @@variables[@@variables.length-2][@var_id] = value
    @@variables.last[@var_id] = value
    @@variables.pop()
    @@variables
  end
end

#Node containing the parameters sent or belonging to a function
#Parameters:
#parameters, a Parameters_Node
#parameter, a Parameter_Node
class Parameters_Node
  def initialize(parameters, parameter)
    @parameters = parameters
    @parameter = parameter
  end

  def eval()
    return_list = Array.new()
    return_list.append(@parameters.eval())
    return_list.append(@parameter)
    return_list.flatten!()
    return return_list
  end
end

#Node containing a parameter sent or belonging to a function
#Parameters:
#parameter, a variable or an identifier
class Parameter_Node
  def initialize(parameter)
    @parameter = parameter
  end

  def eval()
    return Array(@parameter)
  end
end

#This node handles several identifiers_nodes
#Parameters
#ids is an identifiers_node
#id is an identifier_node
class Identifiers_Node
  def initialize(ids, id)
    @ids = ids
    @id = id
  end

  def eval()
    return_list = Array.new()
    return_list.append(@ids.eval())
    return_list.append(@id.eval())
    return_list.flatten!()
    return return_list
  end
end

#This node keeps track of names of variables, classes and functions
#Parameters:
#id is a name made up of regex word characters
class Identifier_Node
  def initialize(id)
    @id = id
  end

  def eval()
    return Array(@id)
  end
end

#Node containing information about what a function shall return
#Parameters:
#id, the id of what to return
class Return_Node
  def initialize(id)
    @id = id
  end

  def eval()
    if @@variables.last[@id] == nil
      return @id
    else
      return @@variables.last[@id]
    end
  end
  attr_reader :id
end

#an instruction is code that can be anything from a print_statment to a loop
#Parameters:
#instruction is a node corresponding to a block of code
#instructions is an instructions node
class Instructions_Node
  def initialize(instruction, instructions)
    @instruction = instruction
    @instructions = instructions
  end

  def eval()
    @instructions.eval()
    @instruction.eval()
  end
end

#Print function used when printing a variable within a class object
#Parameters:
#object, the object which information will be printed from
#variable, the variable within an object to be printed
class Class_Print_Node
  def initialize(object,variable)
    @object = object
    @variable = variable
  end

  def eval()
    puts @@variables.last[@object][@variable]
  end
end

#Print function used to print information to the terminal
#Parameters:
#phrase, what to print, either a string or a variable
class Print_Node
  def initialize(phrase)
    @print_phrase = phrase
  end

  def eval()
    if @print_phrase.class == String
      puts @print_phrase[1..@print_phrase.length()-2]
    elsif @print_phrase.eval.class == String
      puts @print_phrase.eval[1..@print_phrase.eval.length()-2]
    else
      puts @print_phrase.eval()
    end
  end
end

#Node used to create a variable containing data
#Parameters:
#id, the name of the variable
#value, what value the variable shall contain
class Variable_Declaration_Node
  def initialize(id, value)
    @id = id
    @value = value
  end

  def eval()
    @@variables.last[@id] = @value.eval()
  end
end

#Node used to assign a new value to an already existing variable
#Parameters:
#id, the name of the variable which shall be given a new value
#value, the new value the variable shall contain
class Variable_Assignment_Node
  def initialize(id, value)
    @id = id
    @value = value
  end

  def eval()
    if (@@variables.last[@id] == nil)
      raise RuntimeError.new("Variable #{@id} does not exist")
    end
    @@variables.last[@id] = @value.eval()
  end
end

#Node used to create a while loop
#Parameters:
#contition, which determines whether the loop shall continue depending
#on if it's evaluation results in true or false
#instructions, what instructions to be repeated during the loop
class While_Node
  def initialize(condition, instructions)
    @condition = condition
    @instructions = instructions
  end

  def eval()
    while @condition.eval() == false
      if @@break_bool == true
        @@break_bool = false
        return nil
      else
        @instructions.eval()
      end
    end
  end
end

#Node used to iterate over items in a list
#Parameters:
#temp_var, what the current item shall be called in the current iteration
#container, a list to iterate over
#instructions, what instructions to perform during the loop
class For_Each_Node
  def initialize(temp_var, container, instructions)
    @temp_var = temp_var
    @container = container
    @instructions = instructions
  end

  def eval()
    for item in @@variables.last[@container]
      if @@break_bool == true
        @@break_bool = false
        @@variables.last.delete(@temp_var)
        return nil
      else
        @@variables.last[@temp_var] = item
        @instructions.eval()
      end
    end
    @@variables.last.delete(@temp_var)
  end
end

#Node used to create a range based for loop
#Parameters:
#iterations, number of iterations which shall be performed
#instructions, what instructions to perform during the loop
class For_Upto_Node
  def initialize(iterations, instructions)
    @iterations = iterations
    @instructions = instructions
  end

  def eval()
    1.upto(@iterations) do
      if @@break_bool == true
        @@break_bool = false
        return nil
      else
        @instructions.eval()
      end
    end
  end
end

#Node used to create a range based for loop with a variable, allows index
#based loops to be created
#Parameters:
#iterations, number of iterations which shall be performed
#variable, name of the index variable to be used in the loop
#instructions, what instructions to perform during the loop
class For_Upto_Variable_Node
  def initialize(iterations, variable, instructions)
    @variable = variable
    @iterations = iterations
    @@variables.last[@variable] = 0
    @instructions = instructions
  end

  def eval()
    1.upto(@iterations) do |it|
      if @@break_bool == true
        @@break_bool = false
        @@variables.last.delete(@variable)
        return nil
      else
        @@variables.last[@variable] = it
        @instructions.eval()
      end
    end
    @@variables.last.delete(@variable)
  end
end

#Node used to create a range based for loop within a specific range with a variable,
#allows index based loops to be created
#Parameters:
#start, the value of which the index variable shall begin
#stop, the value of which the index variable shall reach and
#therefore quit the loop
#variable, name of the index variable to be used in the loop
#instructions, what instructions to perform during the loop
class For_Range_Variable_Node
  def initialize(start, stop, variable, instructions)
    @variable = variable
    @start = start
    @stop = stop
    @@variables.last[@variable] = start
    @instructions = instructions
  end

  def eval()
    @start.upto(@stop) do |it|
      if @@break_bool == true
        @@break_bool = false
        @@variables.last.delete(@variable)
        return nil
      else
        @@variables.last[@variable] = it
        @instructions.eval()
      end
    end
    @@variables.last.delete(@variable)
  end
end

#This node breaks a loop
class Break_Node
  def initialize()
  end

  def eval()
    @@break_bool = true
  end
end


#-----------------------------------------if-statements
#a node containing an if-statement
#Parameters:
#conditions is a condition that must be true for the instructions to be preformed
#in the form of a conditions_node
#instructions is the instructions to be preformed in the form of an instructions node
class If_Node
  def initialize(condition, instructions)
    @condition = condition
    @instructions = instructions
  end

  def eval()
    if (@condition.eval() == true)
      return @instructions.eval()
    else
      return nil
    end
  end
end

#this is an if_statement with an else-branch
#Parameters:
#conditions is a condition that must be true for the instructions_if to be preformed
#in the form of a conditions_node
#instructions_if is the instructions to be preformed in the form of an instructions node
#if condition is true
#instructions_else is an instructions node that will be preformed otherwise
class If_Else_Node
  def initialize(condition, instructions_if, instructions_else)
    @condition = condition
    @instructions_if = instructions_if
    @instructions_else = instructions_else
  end

  def eval()
    if (@condition.eval() == true)
      return @instructions_if.eval()
    else
      return @instructions_else.eval()
    end
  end
end

#a node containing an if-statement with one or more elif-branches
#Parameters:
#conditions is a condition that must be true for the instructions to be preformed
#in the form of a conditions_node
#instructions is the instructions to be preformed in the form of an instructions node
#otherwise_statements are the elif_branch/elif_branches in the
#form of an otherwise statements_node
class If_Elif_Node
  def initialize(condition, instructions, otherwise_statements)
    @condition = condition
    @instructions = instructions
    @otherwise_statements = otherwise_statements
  end

  def eval()
    if (@condition.eval() == true)
      return @instructions.eval()
    else
      return @otherwise_statements.eval()
    end
  end
end

#this is an if_statement with one or more elif_branches and an else-branch
#Parameters:
#conditions is a condition that must be true for the instructions_if to be preformed
#in the form of a conditions_node
#instructions_if is the instructions to be preformed in the form of an instructions node
#if condition is true
#otherwise_statements are the elif_branch/elif_branches in the
#form of an otherwise statements_node
#instructions_else is an instructions node that will be preformed otherwise
class If_Elif_Else_Node
  def initialize(condition, instructions_if, otherwise_statements, instructions_else)
    @condition = condition
    @instructions_if = instructions_if
    @otherwise_statements = otherwise_statements
    @instructions_else = instructions_else
  end

  def eval()
    if (@condition.eval() == true)
      return @instructions_if.eval()
    else
      if @otherwise_statements.eval() == false
        @instructions_else.eval()
      end
    end
  end
end

#an otherwise_statements_node contains an otherwise_statement_node and an
#otherwise_statements_node
class Otherwise_Statements_Node
  def initialize(statements, statement)
    @statements = statements
    @statement = statement
  end

  def eval()
    if @statements.eval() == false
      @statement.eval()
    end
  end
end

#a node containing an elif-statement
#Parameters:
#conditions is a condition that must be true for the instructions to be preformed
#in the form of a conditions_node
#instructions is the instructions to be preformed in the form of an instructions node
class Otherwise_Statement_Node
  def initialize(condition, instructions)
    @condition = condition
    @instructions = instructions
  end

  def eval()
    if (@condition.eval() == true)
      return @instructions.eval()
    else
      return false
    end
  end
end


#------------------------------------------------Conditions
#Node used to compare conditions by evaluating if at least on of them is true,
#returning true or false depending on result
#Parameters:
#cond1, the first condition to be compared
#cond2, the second condition to be compared
class Or_Node
  def initialize(cond1, cond2)
    @cond1 = cond1
    @cond2 = cond2
  end

  def eval()
    return (@cond1.eval() or @cond2.eval())
  end
end

#Node used to compare conditions by evaluating if both of them are true,
#returning true or false depending on result
#Parameters:
#cond1, the first condition to be compared
#cond2, the second condition to be compared
class And_Node
  def initialize(cond1, cond2)
    @cond1 = cond1
    @cond2 = cond2
  end

  def eval()
    return (@cond1.eval() and @cond2.eval())
  end
end

#Node used to compare conditions by evaluating if they are equal to eachother,
#returning true or false depending on result
#Parameters:
#cond1, the first condition to be compared
#cond2, the second condition to be compared
class Equals_Node
  def initialize(cond1, cond2)
    @cond1 = cond1
    @cond2 = cond2
  end

  def eval()
    return (@cond1.eval() == @cond2.eval())
  end
end

#Node used to compare conditions by evaluating if the first one is less than
#the second, returning true or false depending on result
#Parameters:
#cond1, the first condition to be compared
#cond2, the second condition to be compared
class Lesser_Node
  def initialize(cond1, cond2)
    @cond1 = cond1
    @cond2 = cond2
  end

  def eval()
    return (@cond1.eval() < @cond2.eval())
  end
end

#Node used to compare conditions by evaluating if the first one is greater than
#the second, returning true or false depending on result
#Parameters:
#cond1, the first condition to be compared
#cond2, the second condition to be compared
class Greater_Node
  def initialize(cond1, cond2)
    @cond1 = cond1
    @cond2 = cond2
  end

  def eval()
    return (@cond1.eval() > @cond2.eval())
  end
end

#Node used to return the opposite value of a bool
#Parameters:
#cond, the condition to be evaluated
class Not_Node
  def initialize(cond)
    @cond = cond
  end

  def eval()
    return (not @cond.eval())
  end
end


#----------------------------------Maths
#Node used to calculate terms in a mathematical expression
#Parameters:
#term, the term to be evaluated
class Expression_Node
  def initialize(term)
    @term = term
  end

  def eval()
    return @term.eval()
  end
end

#Node used to calculate addition in a mathematical expression
#Parameters:
#term_a, the first term
#term_b, the second term to be added to the first term
class Addition_Node
  def initialize(term_a, term_b)
    @term_a = term_a
    @term_b = term_b
  end

  def eval()
    return @term_a.eval() + @term_b.eval()
  end
end

#Node used to calculate subtraction in a mathematical expression
#Parameters:
#term_a, the first term
#term_b, the second term to be subtracted from the first term
class Subtraction_Node
  def initialize(term_a, term_b)
    @term_a = term_a
    @term_b = term_b
  end

  def eval()
    return @term_b.eval() - @term_a.eval()
  end
end

#Node used to calculate multiplication in a mathematical expression
#Parameters:
#term_a, the first term
#term_b, the second term to be multiplied with the first term
class Multiplication_Node
  def initialize(factor_a, factor_b)
    @factor_a = factor_a
    @factor_b = factor_b
  end

  def eval()
    return @factor_a.eval() * @factor_b.eval()
  end
end

#Node used to calculate division in a mathematical expression
#Parameters:
#term_a, the first term
#term_b, the second term, which the first term shall be divided with
class Division_Node
  def initialize(factor_a, factor_b)
    @factor_a = factor_a
    @factor_b = factor_b
  end

  def eval()
    return @factor_a.eval() / @factor_b.eval()
  end
end

#Used to return a value to mathematical expressions
#Parameters:
#factor, the factor to be evaluated
class Factor_Node
  def initialize(factor)
    @factor = factor
  end

  def eval()
    return @factor.eval()
  end
end

#Node used to access a variables value
#Parameters:
#id, the id of the variable which value shall be accessed
class Accessor_Node
  def initialize(id)
    @id = id
  end

  def eval()
    if @@variables.last[@id]  == nil
      raise RuntimeError.new("Variable #{@id} does not exist")
    end
    return @@variables.last[@id]
  end
  attr_reader :id
end


#------------------------------------List management
#Creates a list to be handled as a variable
#Parameters:
#id, the name of the variable containing the list
#variables, the items to be inserted into the list
class List_Declaration_Node
  def initialize(id, variables)
    @id = id
    @variables = variables
    @@variables.last[@id] = @variables.eval()
  end

  def eval()
  end
end

#Returns a list created by variables or values received
#Parameters:
#variables, the variables or values that shall be contained in the list
class List_Node
  def initialize(variables)
    @variables = variables
    @list_of_variables = []
  end

  def eval()
    @list_of_variables.append(@variables.eval()).flatten!
    return @list_of_variables
  end
end

#Node used to insert item to the end into existing list
#Parameters:
#variable, the item to be inserted into the list
#id, the id of the list to insert an item to
class List_Insertion_Node
  def initialize(variable, id)
    @variable = variable
    @id = id
  end

  def eval()
    @@variables.last[@id].append(@variable.eval()).flatten!()
  end
end

#Node used to insert item into existing list at a spcific index
#Parameters:
#variable, the item to be inserted into the list
#id, the id of the list to insert an item to
#index, the index at which the item shall be inserted
class List_Index_Insertion_Node
  def initialize(variable, id, index)
    @variable = variable
    @id = id
    @index = index
  end

  def eval()
    @@variables.last[@id].insert(@index, @variable.eval()).flatten!()
  end
end

#this node handles retreiving items from a list from a certain index
#Parameters:
#index is the index that will be accessed
#id is the list that will be accessed from
class List_Access_Node
  def initialize(index, id)
    @index = index
    @id = id
  end

  def eval()
    return @@variables.last[@id][@index-1]
  end
end

#this node handles removing items from a list based on value
#Parameters:
#value is the thing to be removed
#id is the list the thing should be removed from
class List_Item_Removal_Node
  def initialize(value, id)
    @value = value
    @id = id
  end

  def eval()
    @@variables.last[@id].delete(@value.eval())
  end
end

#this nodes handles removing items from a list in an index based way.
#Parameters:
#index is the index that the thing be removed from
#id is the list to remove from
class List_Index_Removal_Node
  def initialize(index, id)
    @id = id
    @index = index
  end

  def eval()
    @@variables.last[@id].delete_at(@index)
  end
end


#---------------------------------------------Variables
#variables_node contains a variable_node and a variables node and returns the
#values of these in the form of a list
class Variables_Node
  def initialize(variable, variables)
    @variables = variables
    @variable = variable
  end

  def eval()
    return_list = Array.new()
    return_list.append(@variable.eval())
    return_list.append(@variables.eval())
    return_list.flatten()
    return return_list
  end
end

#this nodes returns the value of a variable
class Variable_Node
  def initialize(value)
    @value = value
  end

  def eval()
    if @value.class == Accessor_Node
      return @value.eval()
    else
      return @value
    end
  end
end

#a node containing a float
class Float_Node
  def initialize(float)
    @float = float
  end

  def eval()
    return @float.to_f
  end
end

#a node containing a string
class String_Node
  def initialize(string)
    @string =  string
  end

  def eval()
    return @string.to_s
  end
end

#a node containing an integer
class Integer_Node
  def initialize(int)
    @int = int
  end

  def eval()
    return @int.to_i
  end
end

#a node containg a truth value
class Bool_Node
  def initialize(value)
    @value = value
  end

  def eval()
    return value
  end
end
