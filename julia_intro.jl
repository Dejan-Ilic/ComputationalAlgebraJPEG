### A Pluto.jl notebook ###
# v0.17.1

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
First, import the packages we need for this notebook. Pluto notebook then automatically installs them. This might take a while.
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
md"""Only 1 statement per cell is allowed, to get arround this we can use a `begin` block (exposes all its internal variables to the outside world and returns the final expression) or a `let` block (only returns its last value)."""

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

# ╔═╡ 1e03acf5-f049-4a0d-bae2-5af125f1b4c9
md"You can capture the last statement of a `let` block or a `begin` block in a variable:"

# ╔═╡ b9fbc35f-c9d7-4a19-9f12-03644180e2ef
not_so_secret_total = let
	secret_total = sum(1:10)
end

# ╔═╡ 2aa1a20f-699e-483f-8698-92c0fede510e
md"""
### Vectors/Matrices/Arrays

Vectors and Matrices are subtypes of Array. As these examples show, they work as expected. You are strongly encouraged to add new cells of your own and play around."""

# ╔═╡ 154ef61f-ddd2-45e8-aeea-2867af07ea21
a = [1 2 3] #a 1x3 matrix

# ╔═╡ b0a1c2fd-f350-40c3-b680-113a47a90216
b = [1, 2, 3] #a 3x1 vector

# ╔═╡ 3028a080-5ffa-4e44-9edf-f58f945adcd6
c = [1; 2; 3] #a 3x1 vector

# ╔═╡ ae9f854d-6882-445e-ab84-46fbd4b73b31
d = 1:300 #a range object. Behaves like an array, but only stores its start, end and step size.

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

# ╔═╡ ed368908-1618-46dc-9680-0aef69489cbb
md"Note that due to the *reactive* nature of Pluto Notebook updating a global variable, i.e. one that lives outside of a `let` block or a `function`, can have strange/unexpected results."

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
md"""Because Arrays are passed *by reference*, a function can modify the array it receives. By convention, functions that modify (one of) their arguments have their name appended with a "!" (bang). Our function `findmaximumvalue` did not modify the input Array `x`.

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
md"""The solution is to pass the slice *by reference*. In Julia this is done using the `@views` macro. This macro makes sure that all *slices* (e.g. `t[a:b]`) on its line are passed by reference."""

# ╔═╡ 28a70fae-164e-49f6-aea9-92dfd8609be6
let 
	t = [-1 2 -3 4 -5]
	@views replace_neg_with_zero!(t[2:5])
	t
end

# ╔═╡ eab06327-792b-43f9-80c5-f57b8c2581e6
md""" 
You can also use the `@view` macro if you only want to pass a *single* argument by reference and not the others.
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
An engineer skipped a very important part of this tutorial, and wrote the following, incorrect, code. He tried to use the function `foo!` you just defined to set the right half of the 4th row equal to zero. Can you fix his code?
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

# ╔═╡ 44a51e99-5316-430d-a8a1-9decffe224a2
md"**Remark:** I noticed a `@with_terminal` macro in the PlutoUI source code, which might be in the stable release by the time you are using this notebook."

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
cut_in_half("This is a string. This should give an error as we did not define a cut_in_half function for Strings.")

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

Due to the reactive nature of Pluto notebooks, this would also alter the result of `cutInHalf(16)` in the above cell, thus making it impossible to demonstrate the problem.

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

We also annotated the return type for one of the methods to show how this would be done. But again, this is not mandatory and its only purpose is clarity for the reader and a correctness-check for the programmer."""

# ╔═╡ 545fe144-2cec-4f22-b531-1f0fdee68a7a
cutinhalf(16.0)

# ╔═╡ 2912e2eb-7e94-4e16-92a2-40ab785854e8
cutinhalf(16)

# ╔═╡ a19aae44-cad8-4d11-828f-f40c64c8fee8
md"""Now that we understand the basics of Julia syntax and Pluto notebook, we can manipulate some images! On to the next notebook: `jpeg.jl`."""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
Images = "~0.25.0"
Plots = "~1.25.3"
PlutoUI = "~0.7.27"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "265b06e2b1f6a216e0e8f183d28e4d354eab3220"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.2.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

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
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

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
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "84f04fe68a3176a583b864e492578b9466d87f1e"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "3fe985505b4b667e1ae303c9ca64d181f09d5c05"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.3"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

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
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Graphs]]
deps = ["ArnoldiMethod", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "92243c07e786ea3458532e199eb3feee0e7e08eb"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.4.1"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[ImageContrastAdjustment]]
deps = ["ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "0d75cafa80cf22026cea21a8e6cf965295003edc"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.10"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "7a20463713d239a19cbad3f6991e404aca876bda"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.15"

[[ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "15bd05c1c0d5dbb32a9a3d7e0ad2d50dd6167189"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.1"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "OpenEXR", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "a2951c93684551467265e0e32b577914f69532be"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.9"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ea2b6fd947cdfc43c6b8c15cff982533ec1f72cd"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+0"

[[ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "5581e18a74a5838bd919294a7138c2663d065238"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.0"

[[ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1d2d73b14198d10f7f12bf7f8481fd4b3ff5cd61"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.0"

[[ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "36832067ea220818d105d718527d6ed02385bf22"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.7.0"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "d0ac64c9bee0aed6fdbb2bc0e5dfa9a3a78e3acc"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.3"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "b4b161abc8252d68b13c5cc4a5f2ba711b61fec5"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.3"

[[Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "35dc1cd115c57ad705c7db9f6ef5cc14412e8f00"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.0"

[[Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "00019244715621f473d399e4e1842e479a69a42e"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.2"

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
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "5335c4c9a30b4b823d1776d2db09882cbfac9f1e"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.16"

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
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

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

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

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
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

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

[[MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "2af69ff3c024d13bde52b34a2a7d6887d4e7b438"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

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
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

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

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

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
git-tree-sha1 = "6d105d40e30b635cfed9d52ec29cf456e27d38f8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.12"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "646eed6f6a5d8df6708f15ea7e02a7a2c4fe4800"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.10"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

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
git-tree-sha1 = "e4fe0b50af3130ddd25e793b471cb43d5279e3e6"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.1"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "7eda8e2a61e35b7f553172ef3d9eaa5e4e76d92e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.3"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

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

[[Quaternions]]
deps = ["DualNumbers", "LinearAlgebra"]
git-tree-sha1 = "adf644ef95a5e26c8774890a509a55b7791a139f"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.4.2"

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
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "dbf5f991130238f10abbf4f2d255fb2837943c43"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.1.0"

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

[[SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

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
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "7f5a513baec6f122401abfc8e9c074fdac54f6c1"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

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
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

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
git-tree-sha1 = "945b8d87c5e8d5e34e6207ee15edb9d11ae44716"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.3"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

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

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

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
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

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
# ╟─1e03acf5-f049-4a0d-bae2-5af125f1b4c9
# ╠═b9fbc35f-c9d7-4a19-9f12-03644180e2ef
# ╟─2aa1a20f-699e-483f-8698-92c0fede510e
# ╠═154ef61f-ddd2-45e8-aeea-2867af07ea21
# ╠═b0a1c2fd-f350-40c3-b680-113a47a90216
# ╠═3028a080-5ffa-4e44-9edf-f58f945adcd6
# ╠═ae9f854d-6882-445e-ab84-46fbd4b73b31
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
# ╟─ed368908-1618-46dc-9680-0aef69489cbb
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
# ╟─44a51e99-5316-430d-a8a1-9decffe224a2
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
