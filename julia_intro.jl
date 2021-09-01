### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 2f197e3a-7d64-4a26-a9eb-6fcbc0965c10
using Images, PlutoUI, Plots, Random

# ╔═╡ 04f64cf1-0dd5-4a81-91f7-01cd4f71277f
md"""
# Computational Algebra
# JPEG session 

In  this Pluto notebook we will learn the basics of Julia.
"""

# ╔═╡ bbd301c3-c918-4698-ac89-66f0dc971e6d
md"""
## Julia basics
"""

# ╔═╡ c7e44bab-bf81-40d7-97bc-967d16ca3c53
md"""
First, import the packages we need for this notebook. If you have the newest version of Pluto, these packages should be installed automatically. This might take a while.
"""

# ╔═╡ 888db76b-fad6-4f1c-8000-b04a553b190a
md"""Before we can learn about JPEG, we first have to learn some Julia. It is asumed that you have a background in Python or MATLAB.

In the next few sections, you will learn the basics of Julia through some small examples and interactive exercises.

Be aware that the output of a cell containing code appears ABOVE the cell rather than below."""

# ╔═╡ cac3127e-a50a-4e73-acbf-33fe1113690c
md"""### Basic syntax: *if, for, begin, let*
Let's look at some basic syntax, first `if`, `elseif`, `else`, and `&&`, or `||`, not `!`:"""

# ╔═╡ 4ced03dd-ffc9-4f34-8111-926088c8ea30
if π == 3 || sin(1) == 1
	"Engineer"
elseif π == exp(1) && 0 * Inf == 0
	"Criminal"
else
 	"Mathematician"
end

#no print function is needed here. print currently not yet supported in Pluto, only final output is shown

# ╔═╡ 49ccc68d-2ee1-413e-a0f9-761492ec294d
md"""Only 1 statement per cell is allowed, to get arround this we can use a `begin` block (exposes all its internal variables to the outside world) or a `let` block (only returns its last value)."""

# ╔═╡ f4b22329-b72b-4bd2-a3c0-6c60764c0123
begin
	total = 0 #visible to everyone!
	
	for x=1:10
		total += x
	end
	
	total
end

# ╔═╡ 3a5a8e5f-93eb-4943-a51e-6bb751c91f06
total #visible!

# ╔═╡ 55f5374f-4062-4389-9764-2b4ffa4f5740
let
	secret_total = 0 #visible only inside this let block
	
	for x=1:10
		secret_total += x
	end
	
	secret_total
end

# ╔═╡ 82c15347-d499-4b5d-a7dd-7e50c36632c1
secret_total #error, only the value of secret_total is returned from the let block, not secret_total itself.

# ╔═╡ 2aa1a20f-699e-483f-8698-92c0fede510e
md""""
### Vectors/Matrices/Arrays

Vectors and Matrices are subtypes of Array. As these examples show, they work as expected:"""

# ╔═╡ 154ef61f-ddd2-45e8-aeea-2867af07ea21
a = [1 2 3] #a 1x3 matrix

# ╔═╡ b0a1c2fd-f350-40c3-b680-113a47a90216
b = [1, 2, 3] #a 3x1 vector

# ╔═╡ 3028a080-5ffa-4e44-9edf-f58f945adcd6
c = [1; 2; 3] #a 3x1 vector

# ╔═╡ e2cf1bc5-3ea1-4f78-b48d-353bf0816bd9
collect(1:3) #converts a range object start:stop into a dense vector 3x1

# ╔═╡ 05b4d79d-c6b8-4548-b09d-d448f3b1ee37
D = [1 2 3; 4 5 6; collect(7:9)'] #3x3 matrix

# ╔═╡ f4df16e0-a1fd-4b30-8df4-ec4ac72bce42
D*c #a 3x1 vector

# ╔═╡ e0f95a40-c8f0-42af-a3cc-f9e2583f788e
a - b' #transpose to match dimensions

# ╔═╡ b4bf2537-6c7e-4383-bc1b-839ca7ae4ee3
a * b #inner product

# ╔═╡ cf294c1e-fc17-4d96-8a14-b9be0f604d26
b * a #matrix product

# ╔═╡ 98868a6e-22e9-4f3b-9af2-a684fea55d03
b .* c #point-wise product

# ╔═╡ 506e98ce-4e35-4294-a06d-d1a6585779ad
size(D, 1)

# ╔═╡ 3dc11c07-483d-4981-8317-14e0ae077cb7
size(D,2)

# ╔═╡ 18d8d7e5-e517-4fb9-bf52-9711645ec86b
length(D) #number of elements

# ╔═╡ 890e0cf9-6c9e-4ed3-bd17-c35ac0352f5f
md"""
### Array slicing
Nothing out of the ordenary. It is advised to re-run every cell in order because of the reactive nature of Pluto notebooks.

"""

# ╔═╡ 5db1d177-f376-4111-a9ab-d250a7f87ba1
D[:, 1]

# ╔═╡ 79424ae0-8e2e-4f85-aa5f-e30a9aedfa4c
D[:, 1:2:3]  #start:stepsize:stop

# ╔═╡ d8aa5b7c-76d8-4f61-809c-1b45410f7472
D[2:3, 1:2]

# ╔═╡ a8db4a27-bcb9-43f3-b85e-9544c63829f6
D2 = copy(D) #deep copy, D2 = D is shallow copy!

# ╔═╡ 91c1ad84-2ce5-4d0f-ab78-54f732fba609
D3 = D[:, :] #also deep copy, slicing on right hand side always creates new array

# ╔═╡ a52df092-bf28-447e-b6dd-1e4fc122021b
D3[1,1] = 10 #change element in D3

# ╔═╡ 4f0f6f57-eb63-490b-9f01-5aee61358a3a
D3 #changed

# ╔═╡ b03b6b1c-8f17-46cf-a90a-e8d92dbc05a1
D #unchanged

# ╔═╡ 11d947e9-a55d-4392-92c7-5840a0f46fd5
D3[2, :] = c #second row equal to column vector c (no problemo)

# ╔═╡ 8b1cea13-a02f-4b06-8dd6-b0f5f02a7840
D3

# ╔═╡ e89b2b4a-d1a2-4bce-bdcd-354690b3f36f
D3[3, :] = a #third row equal to row vector a

# ╔═╡ b556bbd3-3c0e-4897-93a5-7dd1a4d8a3a2
D3

# ╔═╡ c2bc4183-7d23-4485-a2e8-c991b8c4a1f9
D3[1, :] .= 33 #need dot-syntax if scalar on right hand side

# ╔═╡ 8cda889a-868e-4bbc-9d91-56d494fa73fa
D3

# ╔═╡ 5f50d324-c906-40e8-b67e-edd0a07a58b1
md"""
### Functions
Now let's define some functions. There are two main ways to define a function:
"""

# ╔═╡ cfe065ca-b6c9-4c78-aa97-d6fb170302cf
function f(m::Int, n::Int, x) #arguments CAN be type-annotated, but don't have to be
	return x^m + x^n + 2
end

# ╔═╡ 93a0bdf1-4296-4a3d-a81b-e0a4c1e4e6a1
#one-line functions like this can also be defined as:
f_same(m::Int, n::Int, x) = x^m + x^n + 2

# ╔═╡ 33a7220a-3d1b-49ee-b7b1-f705b5bc90fa
md""" 
The plotting package is notoriously slow to pre-compile, but once compiled very fast. The following code shows how to plot a sine function from `-2` to `2`. Can you adapt it to go from `-π` to `π`? (Yes, Julia supports LaTeX symbols! Just write e.g. `\pi<TAB>`) You can also use `pi` if you don't like fun.
"""

# ╔═╡ e8068e83-baa9-4a60-8128-9e997fa04eb6
let
	t = LinRange(-2, 2, 1000)
	plot(t, sin.(t), framestyle=:origin)
end

# ╔═╡ a065ff8e-162a-4fec-829f-aea530bb299c
md"""
**Remark:** you may have noticed the weird `.` in `sin.(t)`. This is called vectorization. The sine function is only defined on scalars, but in Julia you can make ANY function work on Vectors/Matrices/Arrays by calling it with a dot before the opening bracket. The dot syntax does not affect scalar arguments. More on this in the next sections.

To add a plot to an existing one, you have to use the `plot!` function. Don't forget to wrap all plots in a `begin` or `let` block as a cell can only contain a single expression. 

Try to add a plot of `f` with `m=2` and `n=1`
"""

# ╔═╡ b4ed7228-da36-4846-ab6b-e8d935de6b7d
let
	t = LinRange(-3, 3, 1000) #behaves like a 1000x1 vector
	
	plot(t, sqrt.(t .+ 3), framestyle=:origin) #creates the plot
	plot!(t, t.^2 + 3*t .+ 1)
	
	#add a thrid plot here

end

# ╔═╡ 9f8c7622-b8ab-49e9-be84-bb5dd2738fca
md"""### Functions and Vectors/Matrices/Arrays (extended)

Now let's see how functions and vectors play together in Julia.
"""

# ╔═╡ 3f511a39-0417-40e0-9e4b-80266578c7f3
test_vector1 = [-2 -1 0 1 2]  #1x5: "type: matrix"

# ╔═╡ df9a51a1-80db-437a-b9df-7da4c886b1ce
test_vector2 = [-2, -1, 0, 1, 2] #5x1: "type: vector"

# ╔═╡ 06eba15a-5f14-4082-aa5e-92954f1e411f
test_matrix1 = [1 2 3 4 5; 4 5 6 7 8] #2x5: "type: matrix"

# ╔═╡ 7a3ba94d-4995-40a1-99c0-cee5cf70f86a
md"""Although we have encountered many types (Int and Float for scalars, Vector and Matrix for Arrays, unless you want absolutely optimal performance, you don't have to worry about them.

Let's now apply the function `f(2, 1, .)` element-wise on each of our 3 Arrays (the parent type for Vector and Matrix). Julia has very convinient syntax to do this. Let `v` be an arbitrary Array, then 

`f.(2, 1, v)`

yields the desired result.

#### Exercise:
Complete the following three exercises on vectorization. Your solutions should be stored in the variables `solution1`, `solution2` and `solution3`. Scroll down to the end of the exercise to see whether your solutions were correct (the notebook checks your solutions in real-time).

The first two are warm-up questions and require no further explaination.
"""

# ╔═╡ ef4c6947-7534-4262-8436-92c28fcddb88
solution1 = 0 #apply sin element-wise on test_vector1

# ╔═╡ 2069bc26-71bc-404b-b0f1-8bf25b3d99d1
solution2 = 0 #apply f(2, 1, _) element-wise on test_vector2

# ╔═╡ 35a10f78-df54-4d68-adda-61aea2ef6ddb
md"""A function can also be vectorized in two arguments, if they are Arrays of the same dimensions. To see this, first a new matrix is defined for you, of the same size as `test_matrix1`:"""

# ╔═╡ 37ff6a8b-6352-4a38-b40d-a306cbbd98f7
test_matrix2 = [4 2 4 2 4; 2 4 2 4 2]

# ╔═╡ 2cbf3f7c-367b-47b1-a7b9-2e0821ef365a
md"""Next, you have to define a function `g(x,y)` that takes x to the power `sqrt(abs(y)))`."""

# ╔═╡ db6f0812-f69b-472d-b7dc-8cc0712f5605
function g(x, y) 
	
	return 0 #replace the dummy return value with what is asked
end

# ╔═╡ 2eca82dd-2f58-4e5c-ac01-f09ad0b956f7
md"""Now use this newly defined function `g` and the vectorization syntax to create a new matrix, `solution3`, such that 

`solution3[i,j] = test_matrix1[i,j] ^ sqrt(abs(test_matrix2[i,j]))`"""

# ╔═╡ 0b532231-e5c0-4f25-8353-0f68f90d6bf5
solution3 = 0 #replace this dummy value with the correct value

# ╔═╡ f89febf6-f431-4dd4-88e8-0fcf76ed89e7
let
	sol3(a, b) = a.^sqrt(abs(b))

	md"""
	Check solutions:
	1) **$(solution1 == sin.(test_vector2) ? :correct : :incorrect)**
	2) **$(solution2 == f.(2,1,test_vector1) ? :correct : :incorrect)**
	3) **$(solution3 == sol3.(test_matrix1,test_matrix2) ? :correct : :incorrect)**
	"""
end

# ╔═╡ 2aedcb87-b267-41fb-813f-2c46c61c2111
md"""
### Functions and Vectors/Matrices/Arrays (extended II)
Functions can also take entire Arrays as arguments. Take the next function for example, which takes an arbitrary Array as an input (Vector or Matrix) and finds its maximum value:
"""

# ╔═╡ 14f39cf4-9f11-46b0-aa6a-a8ee6ef1b729
function findmaximumvalue(x::AbstractArray) #type annotate x
	M = x[1]
	
	for i=2:length(x)  #because we iterate over length, matrices/arrays of arbitrary dimension can be accepted by this function
		if x[i] > M
			M = x[i]
		end
	end
	
	return M
end

# ╔═╡ 20cd5b6d-099d-4121-8aad-f683ddff9de5
findmaximumvalue([1 2 3 1000 4 5])

# ╔═╡ aefd62e0-50fa-4d07-8068-b5ac1c194bfc
md"""Because Arrays are passed *by reference*, a function can modify the array it receives. By convention, functions that modify (one of) their arguments have their name appended with a "!" (bang).

Here we wrote `AbstractArray`, which is the parent class of *all* Julia's Vector/Matrix-like classes. This is to not exclude any possible arguments (e.g. SparseArrays, SparseMatrices, SymmetricMatrices, StaticArrays,... all of which are special container classes that *behave* like a normal Array, but aren't necessarily implemented like on under the hood).

#### Exercise
Write a function that receives an Array containing numerical values, and replaces all negative values with zero. The cell below the next cell dynamically checks your solution."""

# ╔═╡ 6b80c27e-b077-4045-aa59-520856da3021
function replace_neg_with_zero!(x::AbstractArray)
	
	#smart code here

	
	return nothing #doesn't have to return anything. "return x" is also possible, it is a matter of taste. I think it is more Julian to return x though. But anyway now you know how to return nothing. If you don't write "return nothing" Julia returns the last statement in the function.
end

# ╔═╡ 506f30ee-c248-4656-a82c-1db34df659ad
let
	t = rand(-4:-1, 20)
	replace_neg_with_zero!(t)
	
	minimum(t) ≥ 0 ?
	md"""**Solution correct!**""" :
	md"""**Solution incorrect!**"""
end

# ╔═╡ bf6cf043-d826-41d6-8c05-568558bc5e1c
md"In this section we used type annotation in the function's arguments. This is not mandatory in Julia. Besides clarity for the reader, it also offers some other advantages which we'll discuss in the section *Type annotation and multiple dispatch*."

# ╔═╡ 3baef1d0-e6c8-4921-960d-dc997085dda0
md"""
### Functions and slices of Arrays (extended III)
As mentioned before, slices, i.e. `A[a:b]` make a copy rather than a reference.  If your have written your 

`replace_neg_with_zero!` 

function correctly, the follow block should return `[0 2 0 4 0]`.
"""

# ╔═╡ a1aa9106-63b6-4154-b0f3-8253726e47a9
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(t)
	t
end

# ╔═╡ f1eada74-107a-4ae0-8f05-efc22f0ba9f8
md"""
However, it won't work here, where we only want to apply the function on the last 4 elements of `t`:
"""

# ╔═╡ e76b2238-7f9a-486d-84a4-6dc46bfcd544
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(t[2:5])
	t
end

# ╔═╡ 6e14eb67-b2b7-473c-a6a5-8b2abe9c9e85
md"""The solution is to pass the slice *by reference*. In Julia this is done using the `@views` macro (for all arguments)"""

# ╔═╡ 28a70fae-164e-49f6-aea9-92dfd8609be6
let 
	t = [-1 2 -3 4 -5]
	@views replace_neg_with_zero!(t[2:5])
	t
end

# ╔═╡ eab06327-792b-43f9-80c5-f57b8c2581e6
md""" 
or with the `@view` macro (for just one argument) 
"""

# ╔═╡ 24694400-4039-41f0-9778-c115a1007502
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(@view(t[2:5]))
	t
end

# ╔═╡ 6c38db6d-0770-4a6e-b865-227a7b658b20
md"""(here it doesn't make any diference because the function only takes one slice as an argument)"""

# ╔═╡ 84ae1279-29b7-4d85-bd0a-6288bb017a95
md"""**Remark:** the `@view` macro should be used with round brackets, like a function call:

`@view( t[a:b, c:d, e:f] )`

The `@views` macro does not require this.
"""

# ╔═╡ d5495d41-41f3-44d1-b6e1-95076073d484
md"""
#### Exercise
Write a function `foo!(mat, row, val)` that replaces all values in row `row` of matrix `mat` with value `val`."""

# ╔═╡ b30ad480-b75e-4b70-9e6c-9d3fe82189c9
function foo!(mat::AbstractMatrix, row::Int, val)
	
	#exercise code here

	return mat #let's be law abiding Julians and return mat from now on
end

# ╔═╡ bfce571e-7948-44b4-8b39-72cf8cb76fa1
let 
	A = rand(4,4)
	foo!(A, 2, 9)
	
	prod(A[2, :] .== 9) ?
	md"""**Solution correct!**""" :
	md"""**Solution incorrect!**"""

end

# ╔═╡ d789ca5a-f8a2-441e-9501-530a8d30cf08
md""" 
An engineer skipped a very important part of this tutorial, and wrote the following, incorrect, code. He tried to use the function `foo!` to set the right half of the 4th row equal to zero. Can you fix his code?
"""

# ╔═╡ 31b79d8d-3718-4c07-acb4-25c4c7fe087c
#matrix definition
begin
	luigi = [1 2 3 4 5 6;
			 6 4 3 1 9 3;
			 6 2 1 9 3 1;
			 2 8 7 1 9 8;
			 2 3 8 9 5 1;
			 3 3 2 2 1 9]	
 	
	foo!(luigi[:, 4:6], 4, 0)
end

# ╔═╡ f28f4546-a51a-4e55-9f84-6246375b20c6
let 
	mario = [1 2 3 4 5 6;
			 6 4 3 1 9 3;
			 6 2 1 9 3 1;
			 2 8 7 0 0 0;
			 2 3 8 9 5 1;
			 3 3 2 2 1 9]	
	
	mario == luigi ?
	md"""**Solution correct!**""" :
	md"""**Solution incorrect!**"""
end

# ╔═╡ effa8e34-a25d-49fb-8c8e-b70d1eb32a5c
luigi

# ╔═╡ f03bafa1-175c-4c9d-8e69-c05ee0c3cd81
md"""**Remark:** in the type annotations, it is often a good idea to write `Abstract{Vector, Matrix, Array}` instead of `{Vector, Matrix, Array}`. The reason being that Julia supports many types of different Vectors, Matrices and Arrays (Sparse, Immutable and even the `@view[s]` macro returns a special subtype of `Abstract{Vector, Matrix, Array}`). Writing general, reusable code is one of the main design philosophies of Julia, and its type system makes this very easy."""

# ╔═╡ 0c947e1e-c6b0-4eca-ab73-8fbd08200dd7
md"""
**Remark:** printing/showing output (currently) is a bit inconvenient in Pluto; all printing should be wrapped within the following block:

`with_terminal() do ... end`

which should also be the last expression of the cell. See the example below. But in future versions this should be more convenient. The following code is an example that shows how to do printing. An alternative is to "just print" and look at the output in the terminal from which Pluto was initiated.
"""

# ╔═╡ 7b83c246-2845-47bc-815b-c455ad29ea51
let
	s = 0
	with_terminal() do 
		for x=1:3
			s+= x
			for y=1:4
				s += y
				println("x=$x, y=$y")
			end
		end
		
		println("The value of honorable variable by the name of s is $s")
	end
end

# ╔═╡ c4e9a74a-fa80-4238-811d-a24ba7c3727b
md"### Type annotations and multiple dispatch
Multiple dispatch is often marketed as Julia's *killer feature*. Let's see what all the fuss is about.

Let's define a function `cut_in_half`. This function should behave differently depending on the type you feed it; e.g. a number should be divided by two, while a Vector should lose it's latter half.

We could write the following code:
"

# ╔═╡ c251bc0b-84ff-4b6f-ad6c-10d77210f072
function cut_in_half(x)
	if typeof(x) <: AbstractVector  #<: "is a subtype of"
		L = length(x)
		return x[1:L÷2]
	elseif typeof(x) <: Number
		return x/2
	else
		return error("cut_in_half not defined for $(typeof(x))")
	end
end

# ╔═╡ 0d017248-abe3-46ae-a592-532b8147e61d
md"This code works as demonstrated by the following exampels:"

# ╔═╡ f28aa4a1-4c56-4461-b5b9-c9f4a11e2111
cut_in_half([1, 2, 3, 4])

# ╔═╡ a2ce01de-d6ec-4564-9d14-11b778954d22
cut_in_half(16)

# ╔═╡ c783a9f7-d22a-4389-9631-846d50fc2a74
cut_in_half("This is a string. This should give an error.")

# ╔═╡ d862d37b-1306-4e4b-a2e3-380ab424b107
md"But it is not very elegant. Moreover, every time we want to add `cut_in_half` behavior for a new type, we have to edit the function. Enter multiple dispatch. Multiple dispatch allows us to overload functions, i.e. have two functions with the same name, based on their type signature. Let's rewrite the `cut_in_half` function as `cutInHalf`:"

# ╔═╡ b72a4588-fed6-441c-8bee-8d5713474691
function cutInHalf(x::Number)
	return x/2
end

# ╔═╡ 09094202-6632-4349-91ad-0a7010352bd4
function cutInHalf(x::AbstractVector)
	return x[1:length(x)÷2]
end

# ╔═╡ fe2f4971-7cde-459d-aa6b-33679f974d7c
md"In Julia we say the *function* `cutInHalf` has 2 *methods*, i.e. one for `Numbers` and one for `AbstractVectors`. Let's demonstrate how to use these functions:"

# ╔═╡ 35795d9a-585c-4b43-9c88-e95428e91fb1
cutInHalf([1,2,3,4])

# ╔═╡ 1edc503a-92bb-40cc-8263-ab7dca6e2d59
cutInHalf(16)

# ╔═╡ 2510ea0e-7630-4f36-a946-ea4a79253c9e
cutInHalf("This is a string. This should AUTOMATICALLY give an error")

# ╔═╡ aba6e772-fe36-4286-bbf5-efb227625797
md"The keen-eyed reader will have noticed that our `cutInHalf` function takes an `Int`[eger] as an input, but outputs a `Float64`. This can be unwanted behavior. 

In Julia, there is an easy solution: define a new *method* for the *function* `cutInHalf` with an `Int` *type signature*.

Due to the reactive nature of Pluto notebooks, this would also alter the result of `cutInHalf(16)`, thus making it impossible to demonstrate the problem.

That's why we change the naming one last time:"

# ╔═╡ 40ab20ce-2553-4c18-85f8-a995bf583f06
function cutinhalf(x::AbstractVector)
	return x[1:length(x)÷2]
end

# ╔═╡ 77e1d120-7f0d-420a-a5f9-0fe68606240d
function cutinhalf(x::Number)
	return x/2
end

# ╔═╡ 66dee6e7-4eb7-4870-98d4-978de24d06d2
function cutinhalf(x::Int)::Int
	return x÷2 #integer division: use \div<TAB>
end

# ╔═╡ 8fc4cef8-6f01-4bb6-bc25-93764c104c0a
md"""Julia follows the simple rule to "always use the *most specialized* method". Because `Int` is more specialized than the more general `Number`, for integers such as 16 the method `cutinhalf(::Int)` will be called, while for floating point numbers such as 16.0, Julia will fall back to the less specialized `cutinhalf(::Number)`.

We also annotated the return type for one of the methods to show how this would be done."""

# ╔═╡ 545fe144-2cec-4f22-b531-1f0fdee68a7a
cutinhalf(16.0)

# ╔═╡ 2912e2eb-7e94-4e16-92a2-40ab785854e8
cutinhalf(16)

# ╔═╡ a19aae44-cad8-4d11-828f-f40c64c8fee8
md"""Now that we understand the basics of Julia syntax, we can manipulate some images!"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Images = "~0.24.1"
Plots = "~1.20.1"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "a4f25b43826d5847c04e925dd846692835956131"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.24"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "9995eb3977fbf67b86d0a0a0508e83017ded03f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.14.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "42a9b08d3f2f951c9b283ea427d96ed9f1f30343"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.5"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "727e463cfebd0c7b999bbf3e9e7e16f254b94193"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.34.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "6d1c23e740a586955645500bbec662476204a52c"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.1"

[[CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "70a0cfd9b1c86b0209e38fbfe6d8231fd606eeaf"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.1"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "937c29268e405b6808d958a9ac41bfe1a31b08e7"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.0"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "182da592436e287758ded5be6e32c406de3a2e47"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.58.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d59e8320c2747553788e4fc42231489cc602fa50"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "44e3b40da000eab4ccb1aecdc4801c040026aeb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.13"

[[IdentityRanges]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be8fcd695c4da16a1d6d0cd213cb88090a150e3b"
uuid = "bbac6d45-d8f3-5730-bfe4-7a449cd117ca"
version = "0.3.1"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[ImageAxes]]
deps = ["AxisArrays", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "794ad1d922c432082bc1aaa9fa8ffbd1fe74e621"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.9"

[[ImageContrastAdjustment]]
deps = ["ColorVectorSpace", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "2e6084db6cccab11fe0bc3e4130bd3d117092ed9"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.7"

[[ImageCore]]
deps = ["AbstractFFTs", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "db645f20b59f060d8cfae696bc9538d13fd86416"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.8.22"

[[ImageDistances]]
deps = ["ColorVectorSpace", "Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "6378c34a3c3a216235210d19b9f495ecfff2f85f"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.13"

[[ImageFiltering]]
deps = ["CatIndices", "ColorVectorSpace", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageCore", "LinearAlgebra", "OffsetArrays", "Requires", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "bf96839133212d3eff4a1c3a80c57abc7cfbf0ce"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.6.21"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "ba5334adebad6bcf43f2586e7151d2c83f09f9b6"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.7"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[ImageMetadata]]
deps = ["AxisArrays", "ColorVectorSpace", "ImageAxes", "ImageCore", "IndirectArrays"]
git-tree-sha1 = "ae76038347dc4edcdb06b541595268fca65b6a42"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.5"

[[ImageMorphology]]
deps = ["ColorVectorSpace", "ImageCore", "LinearAlgebra", "TiledIteration"]
git-tree-sha1 = "68e7cbcd7dfaa3c2f74b0a8ab3066f5de8f2b71d"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.2.11"

[[ImageQualityIndexes]]
deps = ["ColorVectorSpace", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1198f85fa2481a3bb94bf937495ba1916f12b533"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.2.2"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageCore", "OffsetArrays", "Requires", "StackViews"]
git-tree-sha1 = "832abfd709fa436a562db47fd8e81377f72b01f9"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.1"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "IdentityRanges", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "e4cc551e4295a5c96545bb3083058c24b78d4cf0"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.8.13"

[[Images]]
deps = ["AxisArrays", "Base64", "ColorVectorSpace", "FileIO", "Graphics", "ImageAxes", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageShow", "ImageTransformations", "IndirectArrays", "OffsetArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "8b714d5e11c91a0d945717430ec20f9251af4bd2"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.24.1"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "3d682c07e6dd250ed082f883dc88aee7996bf2cc"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.0"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "2ca267b08821e86c5ef4376cffed98a46c2cb205"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[Netpbm]]
deps = ["ColorVectorSpace", "FileIO", "ImageCore"]
git-tree-sha1 = "09589171688f0039f13ebe0fdcc7288f50228b52"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "c0f4a4836e5f3e0763243b8324200af6d0e0f90c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.5"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "520e28d4026d16dcf7b8c8140a3041f0e20a9ca8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.7"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "438d35d2d95ae2c5e8780b330592b6de8494e779"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.3"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "8365fa7758e2e8e4443ce866d6106d8ecbb4474e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.20.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "7dff99fbc740e2f8228c6878e2aad6d7c2678098"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.1"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "adcd36e8ba9665c88eb0bd156d4e2a19f9b0d889"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rotations]]
deps = ["LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "2ed8d8a16d703f900168822d83699b8c3c1a5cd8"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.0.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a322a9493e49c5f3a10b50df3aedaf1cdb3244b7"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.1"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "52c5f816857bfb3291c7d25420b1f4aca0a74d18"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─04f64cf1-0dd5-4a81-91f7-01cd4f71277f
# ╟─bbd301c3-c918-4698-ac89-66f0dc971e6d
# ╟─c7e44bab-bf81-40d7-97bc-967d16ca3c53
# ╠═2f197e3a-7d64-4a26-a9eb-6fcbc0965c10
# ╟─888db76b-fad6-4f1c-8000-b04a553b190a
# ╟─cac3127e-a50a-4e73-acbf-33fe1113690c
# ╠═4ced03dd-ffc9-4f34-8111-926088c8ea30
# ╟─49ccc68d-2ee1-413e-a0f9-761492ec294d
# ╠═f4b22329-b72b-4bd2-a3c0-6c60764c0123
# ╠═3a5a8e5f-93eb-4943-a51e-6bb751c91f06
# ╠═55f5374f-4062-4389-9764-2b4ffa4f5740
# ╠═82c15347-d499-4b5d-a7dd-7e50c36632c1
# ╟─2aa1a20f-699e-483f-8698-92c0fede510e
# ╠═154ef61f-ddd2-45e8-aeea-2867af07ea21
# ╠═b0a1c2fd-f350-40c3-b680-113a47a90216
# ╠═3028a080-5ffa-4e44-9edf-f58f945adcd6
# ╠═e2cf1bc5-3ea1-4f78-b48d-353bf0816bd9
# ╠═05b4d79d-c6b8-4548-b09d-d448f3b1ee37
# ╠═f4df16e0-a1fd-4b30-8df4-ec4ac72bce42
# ╠═e0f95a40-c8f0-42af-a3cc-f9e2583f788e
# ╠═b4bf2537-6c7e-4383-bc1b-839ca7ae4ee3
# ╠═cf294c1e-fc17-4d96-8a14-b9be0f604d26
# ╠═98868a6e-22e9-4f3b-9af2-a684fea55d03
# ╠═506e98ce-4e35-4294-a06d-d1a6585779ad
# ╠═3dc11c07-483d-4981-8317-14e0ae077cb7
# ╠═18d8d7e5-e517-4fb9-bf52-9711645ec86b
# ╟─890e0cf9-6c9e-4ed3-bd17-c35ac0352f5f
# ╠═5db1d177-f376-4111-a9ab-d250a7f87ba1
# ╠═79424ae0-8e2e-4f85-aa5f-e30a9aedfa4c
# ╠═d8aa5b7c-76d8-4f61-809c-1b45410f7472
# ╠═a8db4a27-bcb9-43f3-b85e-9544c63829f6
# ╠═91c1ad84-2ce5-4d0f-ab78-54f732fba609
# ╠═a52df092-bf28-447e-b6dd-1e4fc122021b
# ╠═4f0f6f57-eb63-490b-9f01-5aee61358a3a
# ╠═b03b6b1c-8f17-46cf-a90a-e8d92dbc05a1
# ╠═11d947e9-a55d-4392-92c7-5840a0f46fd5
# ╠═8b1cea13-a02f-4b06-8dd6-b0f5f02a7840
# ╠═e89b2b4a-d1a2-4bce-bdcd-354690b3f36f
# ╠═b556bbd3-3c0e-4897-93a5-7dd1a4d8a3a2
# ╠═c2bc4183-7d23-4485-a2e8-c991b8c4a1f9
# ╠═8cda889a-868e-4bbc-9d91-56d494fa73fa
# ╟─5f50d324-c906-40e8-b67e-edd0a07a58b1
# ╠═cfe065ca-b6c9-4c78-aa97-d6fb170302cf
# ╠═93a0bdf1-4296-4a3d-a81b-e0a4c1e4e6a1
# ╟─33a7220a-3d1b-49ee-b7b1-f705b5bc90fa
# ╠═e8068e83-baa9-4a60-8128-9e997fa04eb6
# ╟─a065ff8e-162a-4fec-829f-aea530bb299c
# ╠═b4ed7228-da36-4846-ab6b-e8d935de6b7d
# ╟─9f8c7622-b8ab-49e9-be84-bb5dd2738fca
# ╠═3f511a39-0417-40e0-9e4b-80266578c7f3
# ╠═df9a51a1-80db-437a-b9df-7da4c886b1ce
# ╠═06eba15a-5f14-4082-aa5e-92954f1e411f
# ╟─7a3ba94d-4995-40a1-99c0-cee5cf70f86a
# ╠═ef4c6947-7534-4262-8436-92c28fcddb88
# ╠═2069bc26-71bc-404b-b0f1-8bf25b3d99d1
# ╟─35a10f78-df54-4d68-adda-61aea2ef6ddb
# ╠═37ff6a8b-6352-4a38-b40d-a306cbbd98f7
# ╟─2cbf3f7c-367b-47b1-a7b9-2e0821ef365a
# ╠═db6f0812-f69b-472d-b7dc-8cc0712f5605
# ╟─2eca82dd-2f58-4e5c-ac01-f09ad0b956f7
# ╠═0b532231-e5c0-4f25-8353-0f68f90d6bf5
# ╟─f89febf6-f431-4dd4-88e8-0fcf76ed89e7
# ╟─2aedcb87-b267-41fb-813f-2c46c61c2111
# ╠═14f39cf4-9f11-46b0-aa6a-a8ee6ef1b729
# ╠═20cd5b6d-099d-4121-8aad-f683ddff9de5
# ╟─aefd62e0-50fa-4d07-8068-b5ac1c194bfc
# ╠═6b80c27e-b077-4045-aa59-520856da3021
# ╟─506f30ee-c248-4656-a82c-1db34df659ad
# ╟─bf6cf043-d826-41d6-8c05-568558bc5e1c
# ╟─3baef1d0-e6c8-4921-960d-dc997085dda0
# ╠═a1aa9106-63b6-4154-b0f3-8253726e47a9
# ╟─f1eada74-107a-4ae0-8f05-efc22f0ba9f8
# ╠═e76b2238-7f9a-486d-84a4-6dc46bfcd544
# ╟─6e14eb67-b2b7-473c-a6a5-8b2abe9c9e85
# ╠═28a70fae-164e-49f6-aea9-92dfd8609be6
# ╟─eab06327-792b-43f9-80c5-f57b8c2581e6
# ╠═24694400-4039-41f0-9778-c115a1007502
# ╟─6c38db6d-0770-4a6e-b865-227a7b658b20
# ╟─84ae1279-29b7-4d85-bd0a-6288bb017a95
# ╟─d5495d41-41f3-44d1-b6e1-95076073d484
# ╠═b30ad480-b75e-4b70-9e6c-9d3fe82189c9
# ╟─bfce571e-7948-44b4-8b39-72cf8cb76fa1
# ╟─d789ca5a-f8a2-441e-9501-530a8d30cf08
# ╠═31b79d8d-3718-4c07-acb4-25c4c7fe087c
# ╟─f28f4546-a51a-4e55-9f84-6246375b20c6
# ╠═effa8e34-a25d-49fb-8c8e-b70d1eb32a5c
# ╟─f03bafa1-175c-4c9d-8e69-c05ee0c3cd81
# ╟─0c947e1e-c6b0-4eca-ab73-8fbd08200dd7
# ╠═7b83c246-2845-47bc-815b-c455ad29ea51
# ╟─c4e9a74a-fa80-4238-811d-a24ba7c3727b
# ╠═c251bc0b-84ff-4b6f-ad6c-10d77210f072
# ╟─0d017248-abe3-46ae-a592-532b8147e61d
# ╠═f28aa4a1-4c56-4461-b5b9-c9f4a11e2111
# ╠═a2ce01de-d6ec-4564-9d14-11b778954d22
# ╠═c783a9f7-d22a-4389-9631-846d50fc2a74
# ╟─d862d37b-1306-4e4b-a2e3-380ab424b107
# ╠═b72a4588-fed6-441c-8bee-8d5713474691
# ╠═09094202-6632-4349-91ad-0a7010352bd4
# ╟─fe2f4971-7cde-459d-aa6b-33679f974d7c
# ╠═35795d9a-585c-4b43-9c88-e95428e91fb1
# ╠═1edc503a-92bb-40cc-8263-ab7dca6e2d59
# ╠═2510ea0e-7630-4f36-a946-ea4a79253c9e
# ╟─aba6e772-fe36-4286-bbf5-efb227625797
# ╠═40ab20ce-2553-4c18-85f8-a995bf583f06
# ╠═77e1d120-7f0d-420a-a5f9-0fe68606240d
# ╠═66dee6e7-4eb7-4870-98d4-978de24d06d2
# ╟─8fc4cef8-6f01-4bb6-bc25-93764c104c0a
# ╠═545fe144-2cec-4f22-b531-1f0fdee68a7a
# ╠═2912e2eb-7e94-4e16-92a2-40ab785854e8
# ╟─a19aae44-cad8-4d11-828f-f40c64c8fee8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
