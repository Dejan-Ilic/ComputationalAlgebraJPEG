### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 7b2079a5-70bd-4efa-9317-c64f062eaae7
using Images, TestImages, PlutoUI, FFTW, Plots, StaticArrays, Random

# ╔═╡ 8e448fd4-6a83-48f0-9345-44322f991a49
begin
	using Interpolations
end

# ╔═╡ 28c4e4ce-bfac-4abd-bd1a-ce936d15c0e6
using LinearAlgebra

# ╔═╡ 0a05e850-cb9f-11eb-39cb-3d183bb8d5a9
md"""
# Computational Algebra
# JPEG session 

In  this Pluto notebook we will learn how the JPEG compression works by implementing it ourselves
"""

# ╔═╡ daac555d-0d99-4cc2-9ee1-b5317d52aad9
md"""
## Julia basics
"""

# ╔═╡ c45c4844-801f-43f5-b62c-ee7b30439b91
md"""
First, import the packages we need for this notebook. If you have the newest version of Pluto, these packages should be installed automatically. This might take a while.
"""

# ╔═╡ c8634d32-c113-4a42-954e-1ab5340562e5
md"""Before we can learn about JPEG, we first have to learn some Julia. It is asumed that you have a background in Python or MATLAB.

In the next few sections, you will learn the basics of Julia through some small examples and interactive exercises.

Be aware that the output of a cell containing code appears ABOVE the cell rather than below."""

# ╔═╡ d63b3c97-8ed0-4cd4-b632-dd32d3180d17
md"""### Basic syntax: *if, for, begin, let*
Let's look at some basic syntax, first `if`, `elseif`, `else`, and `&&`, or `||`, not `!`:"""

# ╔═╡ 1defdc63-e4b3-4ec6-8369-7cd67e957bd4
if π == 3 || sin(1) == 1
	"Engineer"
elseif π == exp(1) && 0 * Inf == 0
	"Criminal"
else
 	"Mathematician"
end

#no print function is needed here. print currently not yet supported in Pluto, only final output is shown

# ╔═╡ 2474a164-147d-48dd-8f77-88e082756d0f
md"""Only 1 statement per cell is allowed, to get arround this we can use a `begin` block (exposes all its internal variables to the outside world) or a `let` block (only returns its last value)."""

# ╔═╡ 3641ea76-46bb-409b-ad7f-a29d955127d4
begin
	total = 0 #visible to everyone!
	
	for x=1:10
		total += x
	end
	
	total
end

# ╔═╡ fafc1904-e1f9-4912-ba4e-c27117ba5677
total #visible!

# ╔═╡ 713299aa-54e1-4462-ae59-49605e6e0e90
let
	secret_total = 0 #visible only inside this let block
	
	for x=1:10
		secret_total += x
	end
	
	secret_total
end

# ╔═╡ bb3748af-d88e-4a81-bec5-75352c617f7a
secret_total #error, only the value of secret_total is returned from the let block, not secret_total itself.

# ╔═╡ 32f5495e-0b87-47aa-9fd5-34e18a489e28
md""""
### Vectors/Matrices/Arrays

Vectors and Matrices are subtypes of Array. As these examples show, they work as expected:"""

# ╔═╡ def23802-a9be-4f25-a06b-24eed090f2ab
a = [1 2 3] #a 1x3 matrix

# ╔═╡ 52c51b6b-29a8-44b2-8638-821462d5264c
b = [1, 2, 3] #a 3x1 vector

# ╔═╡ f90fba79-795b-4285-8b19-444c63a9a34c
c = [1; 2; 3] #a 3x1 vector

# ╔═╡ f53226ee-88b7-48bc-b96f-5c98cb91b179
collect(1:3) #converts a range object start:stop into a dense vector 3x1

# ╔═╡ 222b0e84-cc4a-4fbb-8b89-2f5e24ee811b
D = [1 2 3; 4 5 6; collect(7:9)'] #3x3 matrix

# ╔═╡ 79b1efb8-3fea-4e86-92da-517cdac28773
D*c #a 3x1 vector

# ╔═╡ 72db5304-0ef0-4d56-9424-2465868f6863
a - b' #transpose to match dimensions

# ╔═╡ 8b54df1e-a7fd-4da4-97ed-90349cd27e84
a * b #inner product

# ╔═╡ a9426949-cf67-4415-923e-318663e4a753
b * a #matrix product

# ╔═╡ ad1b44a6-65b9-4a2a-b32b-d9f83d45cd3b
b .* c #point-wise product

# ╔═╡ 4712f8dd-5a2f-4a5f-81c3-e275f05ce97a
size(D, 1)

# ╔═╡ ac45accd-da73-4c7e-8daa-398cc15c2caf
size(D,2)

# ╔═╡ 69537a5a-f0bd-40d7-a681-9a908cb4c883
length(D) #number of elements

# ╔═╡ 95f5eac2-ff17-4eaa-b8e6-b16c13b18b8d
md"""
### Array slicing
Nothing out of the ordenary. It is advised to re-run every cell in order because of the reactive nature of Pluto notebooks.

"""

# ╔═╡ 330b067f-99b6-453b-8ef8-6d6cfa29c541
D[:, 1]

# ╔═╡ ed035485-6c4d-4b6e-ab69-4d5010b5399f
D[:, 1:2:3]  #start:stepsize:stop

# ╔═╡ cc0c6b8b-2552-40ac-a6d8-e0e73d94a631
D[2:3, 1:2]

# ╔═╡ ffc6fd00-90a8-4683-9a2a-0f08e6979b8d
D2 = copy(D) #deep copy, D2 = D is shallow copy!

# ╔═╡ be219366-ae51-4a34-bf94-96e4fe942dfc
D3 = D[:, :] #also deep copy, slicing on right hand side always creates new array

# ╔═╡ 63ac8a21-1a07-4708-b54c-f9efb279414a
D3[1,1] = 10 #change element in D3

# ╔═╡ 5ee06623-5d13-4a5e-b72e-0fc7c983883d
D3 #changed

# ╔═╡ 95b4b482-dd40-420a-a9f2-9a0f377f9db8
D #unchanged

# ╔═╡ 7da385e0-c032-4110-926c-44a2b657a2d3
D3[2, :] = c #second row equal to column vector c (no problemo)

# ╔═╡ bf4260a4-ca5d-418b-985b-515898817320
D3

# ╔═╡ 47017d5e-aad4-41f4-b9c8-533721784646
D3[3, :] = a #third row equal to row vector a

# ╔═╡ 5a5b2db1-ba56-47c2-b5ce-f7647d10016e
D3

# ╔═╡ d3c1e945-17d9-4a07-8805-242c898ea2d6
D3[1, :] .= 33 #need dot-syntax if scalar on right hand side

# ╔═╡ 8954bb72-0421-4073-9a67-4ef12259b760
D3

# ╔═╡ 3d83ac25-23d2-48d8-bdcd-5b76e4210a21
md"""
### Functions
Now let's define some functions. There are two main ways to define a function:
"""

# ╔═╡ b59b26a9-62b2-4a73-aa98-933d42a9d2ca
function f(m::Int, n::Int, x) #arguments CAN be type-annotated, but don't have to be
	return x^m + x^n + 2
end

# ╔═╡ 97af0d61-0c4b-4d6b-8fc4-7ec2c067d5a9
#one-line functions like this can also be defined as:
f_same(m::Int, n::Int, x) = x^m + x^n + 2

# ╔═╡ 8643dfe4-16d1-4f3e-872f-de97b07e1944
md""" 
The plotting package is notoriously slow to pre-compile, but once compiled very fast. The following code shows how to plot a sine function from `-2` to `2`. Can you adapt it to go from `-π` to `π`? (Yes, Julia supports LaTeX symbols! Just write e.g. `\pi<TAB>`) You can also use `pi` if you don't like fun.
"""

# ╔═╡ 349db48e-c1e0-42a2-838d-db5267cadc3d
let
	t = LinRange(-2, 2, 1000)
	plot(t, sin.(t), framestyle=:origin)
end

# ╔═╡ 505a5eac-f0be-4969-889b-97f5ffc406da
md"""
**Remark:** you may have noticed the weird `.` in `sin.(t)`. This is called vectorization. The sine function is only defined on scalars, but in Julia you can make ANY function work on Vectors/Matrices/Arrays by calling it with a dot before the opening bracket. The dot syntax does not affect scalar arguments. More on this in the next sections.

To add a plot to an existing one, you have to use the `plot!` function. Don't forget to wrap all plots in a `begin` or `let` block as a cell can only contain a single expression. 

Try to add a plot of `f` with `m=2` and `n=1`
"""

# ╔═╡ 1b6ffe16-7b63-41c1-84c8-87aabe51badc
let
	t = LinRange(-3, 3, 1000) #behaves like a 1000x1 vector
	
	plot(t, sqrt.(t .+ 3), framestyle=:origin) #creates the plot
	plot!(t, t.^2 + 3*t .+ 1)
	
	#add a thrid plot here

end

# ╔═╡ 268cfedb-e3a2-4bdf-9173-5395bb618b37
md"""### Functions and Vectors/Matrices/Arrays (extended)

Now let's see how functions and vectors play together in Julia.
"""

# ╔═╡ 039d1246-2189-42d7-859b-1f0358a3ed3c
test_vector1 = [-2 -1 0 1 2]  #1x5: "type: matrix"

# ╔═╡ 85a68539-044e-4f8d-a065-7e747bde4c83
test_vector2 = [-2, -1, 0, 1, 2] #5x1: "type: vector"

# ╔═╡ e1c506e9-bc39-4142-abec-5b7322528e70
test_matrix1 = [1 2 3 4 5; 4 5 6 7 8] #2x5: "type: matrix"

# ╔═╡ 70c3ea70-bace-47eb-84cf-b246ab300b23
md"""Although we have encountered many types (Int and Float for scalars, Vector and Matrix for Arrays, unless you want absolutely optimal performance, you don't have to worry about them.

Let's now apply the function `f(2, 1, .)` element-wise on each of our 3 Arrays (the parent type for Vector and Matrix). Julia has very convinient syntax to do this. Let `v` be an arbitrary Array, then 

`f.(2, 1, v)`

yields the desired result.

#### Exercise:
Complete the following three exercises on vectorization. Your solutions should be stored in the variables `solution1`, `solution2` and `solution3`. Scroll down to the end of the exercise to see whether your solutions were correct (the notebook checks your solutions in real-time).

The first two are warm-up questions and require no further explaination.
"""

# ╔═╡ f0259140-3167-4ad8-a1ae-f9c8d0d2d77c
solution1 = 0 #apply sin element-wise on test_vector1

# ╔═╡ 05c9f15b-bfb3-43a5-ad6c-0a14f127b96d
solution2 = 0 #apply f(2, 1, _) element-wise on test_vector2

# ╔═╡ 754fddfe-2f2c-448c-9d8c-dec5d994408f
md"""A function can also be vectorized in two arguments, if they are Arrays of the same dimensions. To see this, first a new matrix is defined for you, of the same size as `test_matrix1`:"""

# ╔═╡ f1636d30-8527-467a-99b6-6eac97c59c61
test_matrix2 = [4 2 4 2 4; 2 4 2 4 2]

# ╔═╡ 6103db78-7b43-47dd-a1dd-4637c38b898b
md"""Next, you have to define a function `g(x,y)` that takes x to the power `sqrt(abs(y)))`."""

# ╔═╡ 5a9d52bf-11b0-40ca-946c-ed7248fbbf20
function g(x, y) 
	
	return 0 #replace the dummy return value with what is asked
end

# ╔═╡ 3f60a50a-aaab-401b-ae81-cacc347fc947
md"""Now use this newly defined function `g` and the vectorization syntax to create a new matrix, `solution3`, such that 

`solution3[i,j] = test_matrix1[i,j] ^ sqrt(abs(test_matrix2[i,j]))`"""

# ╔═╡ 177870cf-677c-45e2-972a-d56b8ced29f0
solution3 = 0 #replace this dummy value with the correct value

# ╔═╡ 7bb1bd36-6a51-4a41-b794-ed49ffeefef6
let
	sol3(a, b) = a.^sqrt(abs(b))

	md"""
	Check solutions:
	1) $(solution1 == sin.(test_vector2) ? :correct : :incorrect)
	2) $(solution2 == f.(2,1,test_vector1) ? :correct : :incorrect)
	3) $(solution3 == sol3.(test_matrix1,test_matrix2) ? :correct : :incorrect)
	"""
end

# ╔═╡ 1005e439-e51e-4051-8dd8-627aff03dc17
md"""
### Functions and Vectors/Matrices/Arrays (extended II)
Functions can also take entire Arrays as arguments. Take the next function for example, which takes an arbitrary Array as an input (Vector or Matrix) and finds its maximum value:
"""

# ╔═╡ fb31605e-fc08-4ec9-8872-cf47020b9701
function findmaximumvalue(x::AbstractArray) #type annotate x
	M = x[1]
	
	for i=2:length(x)  #because we iterate over length, matrices/arrays of arbitrary dimension can be accepted by this function
		if x[i] > M
			M = x[i]
		end
	end
	
	return M
end
			

# ╔═╡ 518208c6-a179-40bf-819d-162871b2df71
findmaximumvalue([1 2 3 1000 4 5])

# ╔═╡ 2891c2f0-4a1f-4cad-b48e-b40e4c33b7c6
md"""Because Arrays are passed *by reference*, a function can modify the array it receives. By convention, functions that modify (one of) their arguments have their name appended with a "!" (bang).

Here we wrote `AbstractArray`, which is the parent class of *all* Julia's Vector/Matrix-like classes. This is to not exclude any possible arguments (e.g. SparseArrays, SparseMatrices, SymmetricMatrices, StaticArrays,... all of which are special container classes that *behave* like a normal Array, but aren't necessarily implemented like on under the hood).

#### Exercise
Write a function that receives an Array containing numerical values, and replaces all negative values with zero. The cell below the next cell dynamically checks your solution."""

# ╔═╡ d7e8900e-64b1-4866-94bd-786b3af99d8d
function replace_neg_with_zero!(x::AbstractArray)
	
	#smart code here

	
	return nothing #doesn't have to return anything. "return x" is also possible, it is a matter of taste. I think it is more Julian to return x though. But anyway now you know how to return nothing. If you don't write "return nothing" Julia returns the last statement in the function.
end

# ╔═╡ d5774ec1-87ad-47d7-a1df-ba4c2ac4cbe2
let
	t = rand(-4:-1, 20)
	replace_neg_with_zero!(t)
	
	minimum(t) ≥ 0 ?
	md"""**Solution correct!**""" :
	md"""**Solution incorrect!**"""
end
	

# ╔═╡ 086f76c4-5d9a-47d9-b3d2-1ae168e24a6c
md"In this section we used type annotation in the function's arguments. This is not mandatory in Julia. Besides clarity for the reader, it also offers some other advantages which we'll discuss in the section *Type annotation and multiple dispatch*."

# ╔═╡ 17384aa0-7e76-44b3-931e-38099bd4ff6d
md"""
### Functions and slices of Arrays (extended III)
As mentioned before, slices, i.e. `A[a:b]` make a copy rather than a reference.  If your have written your 

`replace_neg_with_zero!` 

function correctly, the follow block should return `[0 2 0 4 0]`.
"""

# ╔═╡ d9113067-8787-4a18-a5fc-9011a44a2173
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(t)
	t
end

# ╔═╡ 1c94f4c3-38e7-48a1-8b5f-e15a821b0a4e
md"""
However, it won't work here, where we only want to apply the function on the last 4 elements of `t`:
"""

# ╔═╡ 9a925811-bb2e-4b30-8521-a04d7b411820
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(t[2:5])
	t
end

# ╔═╡ bd915961-5602-465c-9c99-0623481a9272
md"""The solution is to pass the slice *by reference*. In Julia this is done using the `@views` macro (for all arguments)"""

# ╔═╡ 0c8e29c3-d896-48db-986b-8bfc635b17be
let 
	t = [-1 2 -3 4 -5]
	@views replace_neg_with_zero!(t[2:5])
	t
end

# ╔═╡ 93e518f1-47fe-48d8-990a-78eca8f2d4c3
md""" 
or with the `@view` macro (for just one argument) 
"""

# ╔═╡ e456f2fc-cae5-4c9a-91d2-b3184561606d
let 
	t = [-1 2 -3 4 -5]
	replace_neg_with_zero!(@view(t[2:5]))
	t
end

# ╔═╡ e4021a39-7e9f-479b-9d69-95447c6cc9dd
md"""(here it doesn't make any diference because the function only takes one slice as an argument)"""

# ╔═╡ 024e2a32-d4f2-4114-8968-bb7e31a9c8fd
md"""**Remark:** the `@view` macro should be used with round brackets, like a function call:

`@view( t[a:b, c:d, e:f] )`

The `@views` macro doesn't require this.
"""

# ╔═╡ f16510d8-3a13-4881-b83f-c41668f96c4d
md"""
#### Exercise
Write a function `foo!(mat, row, val)` that replaces all values in row `row` of matrix `mat` with value `val`."""

# ╔═╡ 4c6d074a-6564-4a45-bcf3-fb417e4d2ba1
function foo!(mat::AbstractMatrix, row::Int, val)
	
	#exercise code here

	return mat #let's be law abiding Julians and return mat from now on
end

# ╔═╡ 1f09d825-e884-415d-a4c5-8ad62938c0ff
let 
	A = rand(4,4)
	foo!(A, 2, 9)
	
	prod(A[2, :] .== 9) ?
	md"""**Solution correct!**""" :
	md"""**Solution incorrect!**"""

end

# ╔═╡ 5a4ca684-0375-4a23-b480-b8ab4e2dc26e
md""" 
An engineer skipped a very important part of this tutorial, and wrote the following, incorrect, code. He tried to use the function `foo!` to set the right half of the 4th row equal to zero. Can you fix his code?
"""

# ╔═╡ 34590bcf-5804-4e96-b869-3f9709475b43
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

# ╔═╡ 8ba9d6ae-ad53-4191-b710-74549e039ab7
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

# ╔═╡ 954d43cd-71f1-44b8-b073-ade1e74cdddb
luigi

# ╔═╡ 960c07a7-9f4e-4a75-a1b4-e8bd27968312
md"""**Remark:** in the type annotations, it is often a good idea to write `Abstract{Vector, Matrix, Array}` instead of `{Vector, Matrix, Array}`. The reason being that Julia supports many types of different Vectors, Matrices and Arrays (Sparse, Immutable and even the `@view[s]` macro returns a special subtype of `Abstract{Vector, Matrix, Array}`). Writing general, reusable code is one of the main design philosophies of Julia, and its type system makes this very easy."""

# ╔═╡ 483c2f13-53b4-4149-b517-91e25e9ce32f
md"""
**Remark:** printing/showing output (currently) is a bit inconvenient in Pluto; all printing should be wrapped within the following block:

`with_terminal() do ... end`

which should also be the last expression of the cell. See the example below. But in future versions this should be more convenient. The following code is an example that shows how to do printing. An alternative is to "just print" and look at the output in the terminal from which Pluto was initiated.
"""

# ╔═╡ 65335b08-0a73-4e6e-9fcd-c734ac2689eb
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

# ╔═╡ 57a8da57-cd62-4f23-823f-6832b0556d95
md"### Type annotations and multiple dispatch
Multiple dispatch is often marketed as Julia's *killer feature*. Let's see what all the fuss is about.

Let's define a function `cut_in_half`. This function should behave differently depending on the type you feed it; e.g. a number should be divided by two, while a Vector should lose it's latter half.

We could write the following code:
"

# ╔═╡ dd14c65f-f75c-4049-8b7d-1aced363128d
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

# ╔═╡ efbb1823-4544-4a38-8355-00c6ecc0ed15
md"This code works as demonstrated by the following exampels:"

# ╔═╡ e1c3e6e4-5c85-4b94-a46a-62a5c360d87c
cut_in_half([1, 2, 3, 4])

# ╔═╡ de94e237-ac88-4af7-9a4a-edfdf472d05f
cut_in_half(16)

# ╔═╡ 0af95729-e596-4382-ada7-0093fb909796
cut_in_half("This is a string. This should give an error.")

# ╔═╡ db3ed199-8efd-4e13-b361-54e1becebf7a
md"But it is not very elegant. Moreover, every time we want to add `cut_in_half` behavior for a new type, we have to edit the function. Enter multiple dispatch. Multiple dispatch allows us to overload functions, i.e. have two functions with the same name, based on their type signature. Let's rewrite the `cut_in_half` function as `cutInHalf`:"

# ╔═╡ fba92f2c-e0a8-4a82-b063-811146ef09eb
function cutInHalf(x::Number)
	return x/2
end

# ╔═╡ 1c34938a-a05b-4855-9744-e307cea8863b
function cutInHalf(x::AbstractVector)
	return x[1:length(x)÷2]
end

# ╔═╡ 8d21f297-5a7f-4640-bb8a-69b4e436168a
md"In Julia we say the *function* `cutInHalf` has 2 *methods*, i.e. one for `Numbers` and one for `AbstractVectors`. Let's demonstrate how to use these functions:"

# ╔═╡ 981bf301-5ad7-4b16-8a10-b1ce7449ff66
cutInHalf([1,2,3,4])

# ╔═╡ 97f9aa49-1420-4b05-b0ea-46ffb439ad92
cutInHalf(16)

# ╔═╡ bb4f1863-2948-428c-8124-c3927dacbcc4
cutInHalf("This is a string. This should AUTOMATICALLY give an error")

# ╔═╡ 52935cae-f774-4298-be8c-b379ec1c1b7a
md"The keen-eyed reader will have noticed that our `cutInHalf` function takes an `Int`[eger] as an input, but outputs a `Float64`. This can be unwanted behavior. 

In Julia, there is an easy solution: define a new *method* for the *function* `cutInHalf` with an `Int` *type signature*.

Due to the reactive nature of Pluto notebooks, this would also alter the result of `cutInHalf(16)`, thus making it impossible to demonstrate the problem.

That's why we change the naming one last time:"

# ╔═╡ 393ed59c-8cc3-48a8-9fed-ec44e15db10a
function cutinhalf(x::AbstractVector)
	return x[1:length(x)÷2]
end

# ╔═╡ 3754be18-d417-4d26-af28-7e8c1d7ab4cc
function cutinhalf(x::Number)
	return x/2
end

# ╔═╡ bb1b79d0-0c35-49c6-8e54-ca01e017a242
function cutinhalf(x::Int)::Int
	return x÷2 #integer division: use \div<TAB>
end

# ╔═╡ 267b2b47-79a0-4488-9a86-90f86b3b4e2e
md"""Julia follows the simple rule to "always use the *most specialized* method". Because `Int` is more specialized than the more general `Number`, for integers such as 16 the method `cutinhalf(::Int)` will be called, while for floating point numbers such as 16.0, Julia will fall back to the less specialized `cutinhalf(::Number)`.

We also annotated the return type for one of the methods to show how this would be done."""

# ╔═╡ cab9e98f-5967-4fbc-bc6a-173912c5a05a
cutinhalf(16.0)

# ╔═╡ df6e7b9d-9c76-4447-aab8-2d427f063392
cutinhalf(16)

# ╔═╡ 6d8c5631-55b0-4e98-b9cb-91bd33a7a32f
md"""Now that we understand the basics of Julia syntax, we can manipulate some images!"""

# ╔═╡ fd056009-de33-460a-8475-8e93d6e02d46
md"""
## Images
### Image representation
"""

# ╔═╡ ea1994ed-a14e-4df9-b008-9eeefe69a831
md"""Let's load our test image for today"""

# ╔═╡ 4f6c5da3-3d86-46d9-8e4d-c3f254fbd90e
mandrill = testimage("mandrill")

# ╔═╡ 644db8e8-9c18-4ea5-be45-17935b807ad9
md"""In Julia, images are 2D matrices of RGB objects. To see the underlying 3 x $(size(mandrill,1)) x $(size(mandrill,2)) 3D matrix, we can use the `channelview` function (scroll sideways to see all three "pages" of the 3D matrix).

Its output can be interpreted as 3 _pages_ of size $(size(mandrill,1)) x $(size(mandrill,2)). Note that pixels have values between 0 (black) and 1 (white). In MATLAB, depending on the data type (integer resp. float) intensity values range between 0 and 255, resp. 0 and 1. In Julia they always range between 0 and 1 because integer intensities `i` are interpreted as `i/255`.
"""

# ╔═╡ 2e96aab5-fc7a-4f2a-a2b4-ed27a9b7004b
channelview(mandrill)[1, :, :], channelview(mandrill)[2, :, :],  channelview(mandrill)[3, :, :]

# ╔═╡ 5e359f41-d768-4cd7-afd6-5b98806ed9a4
md"""Let's tear the pages apart and store them in regular 2D matrices `R`, `G` and `B`."""

# ╔═╡ 1ce58807-094b-4576-8fd4-9281ec8bf90d
begin
	R = channelview(mandrill)[1, :, :]
	G = channelview(mandrill)[2, :, :]
	B = channelview(mandrill)[3, :, :]
end #output will only show B

# ╔═╡ 84c7d5f7-2ecc-414e-89b3-1a746c583eee
md"""Using some library functions, we can stack the R matrix on top of 2 zero arrays, which dims out the G and B channel. We do the same with the G and B channel (don't worry about code)."""

# ╔═╡ 3ba49ed0-86f8-44d7-ad8c-919e18e39b3b
hcat(colorview(RGB, StackedView(R, zeroarray, zeroarray)), colorview(RGB, StackedView(zeroarray, G, zeroarray)), colorview(RGB, StackedView(zeroarray, zeroarray, B)))

# ╔═╡ d043cadb-d0ac-4570-a669-56b4718a62ec
md"The following sliders control the proportion, `0% - 100%`, of the respective channels that is let through in the next example.

Red: $(@bind R_intensity Slider(LinRange(0,1,101), 1, true))

Green: $(@bind G_intensity Slider(LinRange(0,1,101), 1, true))

Blue: $(@bind B_intensity Slider(LinRange(0,1,101), 1, true))
"

# ╔═╡ 34e2cee3-583c-4f30-bef7-676d30b76935
colorview(RGB, R_intensity * R, G_intensity * G, B_intensity * B)

# ╔═╡ 892d5edb-f572-41f4-b328-4dc0a0adf8ed
md"""Being mathematicians (or computer scientists? can they also take this course?) we of course immediately realize that an RGB image is just a stack of 3 grayscale images! This means we can develop our compression techniques on a single channel."""

# ╔═╡ e031b0fd-acc6-4552-93b5-ba6208848c6e
ape = Gray.(mandrill) #julia vectorize syntax

# ╔═╡ b8e78721-fab9-4e10-bcd4-a3e2fed3e4d6
md"""**Remark:** the ``RGB`` *color space* is just one way to store color coordinates. If you think of RGB as analogous to Cartesian coordinates, then there also exist color space which are analogous to polar coordinates. 
  
The ``HSI`` (hue - saturation - insentity) color space separates color information (hue: what color; and saturation: low: pastel and high: cartoon) from intensity information. In this sense HSI is very much like (θ, ϕ, ρ). 
  
Such representations that separate color information from intensity information are commonly used in image compression as the human eye is much more sensitive to intensity information than to color information. This means that greater compression without visual loss can be achieved by heavily compressing the channels that contain color information while leaving the intensity information more in tact.
  
JPEG converts color to ``YC_bC_r`` where ``Y`` can be seen as the average intensity and, ``C_b`` and ``C_r`` as the blue and red shift. This is a linear transform which is probably why it was chosen over others.
"""

# ╔═╡ 34df0824-f264-4493-b7b4-0c9946d03310
mandrill_HSI = convert.(HSI, mandrill);

# ╔═╡ e596f8c0-a7e7-4e92-99a8-3da11620aeab
md"
Control `S` in `HUE` image:
$(@bind HUE_s Slider(LinRange(0,1,100)))

Control `H` in `SAT` image: $(@bind SAT_s Slider(0:360))
Control `I` in `SAT` image: $(@bind SAT_i Slider(LinRange(0,1,100)))

"

# ╔═╡ f976fa97-08c9-4a87-90fd-3d757359a53b
let
	H = channelview(mandrill_HSI)[1, :, :]
	S = channelview(mandrill_HSI)[2, :, :]
	I = channelview(mandrill_HSI)[3, :, :]
	
	onearray = ones(size(H))
	
	hcat(colorview(HSI, StackedView(H, HUE_s*onearray, 0.5 * onearray)), colorview(HSI, StackedView(SAT_s*onearray, S, SAT_i*onearray)), colorview(HSI, StackedView(zeroarray, zeroarray, I)))
	
end


# ╔═╡ c81c323f-3137-46e3-8b54-445a440f1cf9
md"**Exercise:** try to make sliders that modify values `α`, `β` and `γ`. Then display

`colorview(HSI, StackedView(α * H, β * S, γ * I))`

in the next cell. Experiment with different ranges."

# ╔═╡ bb5ff4d0-854b-4297-a887-9062ad6c1a9e


# ╔═╡ df78b4cb-25a1-41a5-9dce-251f827bd246


# ╔═╡ d5feba51-64c7-4dfd-97b5-283be7e969dc
md"""
### DCT
Vanaf hier is alles test-onzin


``\LaTeX`` test: Here's some inline maths: ``\sqrt[n]{1 + x + x^2 + \ldots}``.

Here's an equation:

``\frac{n!}{k!(n - k)!} = \binom{n}{k}``

This is the binomial coefficient.
"""

# ╔═╡ e6105acc-5fa6-453f-9b8e-c7e31d6834b6
md"``2\times 2`` images can be constructed from the *standard* basis
```math
\left\{ \left[\begin{array}{cc} 1 & 0\\ 0&0\end{array}\right], \left[\begin{array}{cc} 0 & 1\\ 0&0\end{array}\right],\left[\begin{array}{cc} 0 & 0\\ 1&0\end{array}\right],\left[\begin{array}{cc} 0 & 1\\ 0&0\end{array}\right] \right\}
```
"

# ╔═╡ 3a77a494-d17a-4bcc-b59f-4668c07e31bc
md"Now use a list comprehension to define the standard basis for ``8\times 8`` image patches."

# ╔═╡ 5e78fe3d-4c9a-4597-9ca1-b641874e5996
#make a 8x8 base image generating function
function baseimg(k)
	M = zeros(8,8)
	M[k] = 1
	return M
end

# ╔═╡ dcb663f8-5a49-420b-85ba-17b8d60febcc
#Visualize it
baseimg(10)

# ╔═╡ 742d65cb-3196-4ace-8e91-65cb4b208696
#Pretty view
Gray.(baseimg(46))

# ╔═╡ c26e53eb-cfbb-40df-8f11-67d0bb3add1f
#now make stdbase list
[Gray.(baseimg(k)) for k=1:64]

# ╔═╡ 45b39cd3-e104-49ca-9a88-3b0ece4edb18
#now make stdbase matrix
[Gray.(baseimg(8*i + j + 1)) for i=0:7, j=0:7]

# ╔═╡ 4c6f736f-217a-46c5-87d1-3377f9daa953
#make dct base image function
dctbasis(k) = idct(baseimg(k))

# ╔═╡ 44fb2e5e-4f95-4d08-a1c1-73cda73fca9c
#test it
dctbasis(2)

# ╔═╡ 7cb01529-b500-4729-8cab-be5985739489
#define rescale function
function rescale(U)
	m = minimum(U)
	M = maximum(U)
	return Gray.(  (U .- m)/(M - m))
end

# ╔═╡ 6d120b0b-ae51-4874-ae6b-17ed42f1fecf
#test it
rescale(dctbasis(6))

# ╔═╡ 97ea5326-cbf0-4e56-92fb-e692c5867e77
#matrix it
[rescale(dctbasis(8*i + j + 1)) for i=0:7, j=0:7]

# ╔═╡ 6b5368f1-ac22-489b-a95b-d51696472e17
#same with real(fft)
fftbasis(k) = real(ifft(baseimg(k)))

# ╔═╡ c32eaf9d-3939-40ec-a7fb-83b911387591
#visualize matrix
[rescale(fftbasis(8*i + j + 1)) for i=0:7, j=0:7]

# ╔═╡ 9f01b2fc-1122-449a-92c9-663c734b3eff
md"""
Een poging om buiten inline ``f(x) = \sin(x^{\sqrt{22}})`` ook
```math
\begin{equation}
\partial^2 \approx 7
\end{equation}
```
en dan verder
```math
\sqrt{\frac{\int_0^\infty f(u) du}{\frac{df}{dx}}} = \int_0^\infty \sin\sum
```
te doen

"""

# ╔═╡ d33ef724-4bb7-4be5-a9cf-14a928fb2289
let
	function decode_channel(F)
		f = similar(F)
		C(u) = sqrt(1/2)^Float64(u==0);

		for blockx=0:(size(f,2)÷8-1)
			for blocky=0:(size(f,1)÷8 - 1)
				F_sub = F[ (blocky*8+1):(blocky*8+8), (blockx*8+1):(blockx*8+8)];
				u = (0:7)';
				v = (0:7)';
				for x=0:7
					cos_vec_xu = @. cos( (2* x + 1) * u * pi/16);
					for y=0:7
						cos_vec_yv = @. cos( (2* y + 1) * (0:7)' * pi/16);

						cos_vec = (cos_vec_xu' * cos_vec_yv);
						C_sub = @. C(u)' * C(v);

						tot = sum(sum( F_sub .* C_sub .* cos_vec));

						f[blocky*8 + x + 1, blockx*8 + y + 1] = 1/4*tot;
					end
				end
			end
		end

		f = f .+ 128;

		return f
	end
	
	
	c = 1016;
	T = ones(8*8 + 7, 8*8 + 7)*(-1);
	F = zeros(8, 8);

	for i=1:8
		for j=1:8
			F[i,j] = c;
			df = floor.(decode_channel(F));
			F[i,j] = 0;

			i1 = 1 + (i-1)*9;
			j1 = 1 + (j-1)*9;

			dfmax = maximum(maximum(df))
			dfmin = minimum(minimum(df))

			T[i1:(i1+7), j1:(j1+7)] = floor.( (df .- dfmin) / (dfmax - dfmin) * 255 .+ 0.5)
		end
	end

	#T = imresize(T, 12, 'nearest');
	T[1:8, 1:8] .= 255; #anders is de bovenste tegel zwart.

	Tr = deepcopy(T);
	Tr[Tr .== -1] .= 255;
	T[T .== -1] .= 0;

	T = T / 255
	Tr = Tr / 255


	imresize(RGB.(Tr, T, T), method=Interpolations.Constant(), ratio=8)
end

# ╔═╡ bbc98009-e757-4936-8251-d57426b8cb9b


# ╔═╡ 8425a6ff-b968-4245-b351-face7d874a2b


# ╔═╡ 371b82c0-518f-4a23-8d83-9775aefdfb76


# ╔═╡ 9da5dc21-db80-4ea1-b54d-d774bd8c94a4


# ╔═╡ 226b6612-7f60-44c6-8452-cba9b318b1ca
md""" 
## How do images work?
"""

# ╔═╡ 72de7fb2-8288-4bc5-8293-eeed4016563f
md""" Blablabla en

``\sum_{x=0}^{N-1} f(x)e^{\frac{2\pi i x}{N}}`` 

is een som in Latex.
"""

# ╔═╡ 807854a1-032f-4dd9-8e50-895b92d23322
H = zeros(4,4)

# ╔═╡ 4ce1ccad-36a4-41be-97e6-10fc4586cdad
h = [8 9 14]

# ╔═╡ 6ce1d16b-479f-4175-9943-fbc611dcee9c
let 
	a = [1 2 3 4]
	vec(a)
	diagm(vec(a))
end

# ╔═╡ de0ba933-75c6-4548-8e95-78bfba8e6d4a


# ╔═╡ d6ed210d-2774-4a16-8f02-2e0391dce749
function u(α)
	return π * α
end 

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
TestImages = "5e47fb64-e119-507b-a336-dd2b206d9990"

[compat]
FFTW = "~1.4.3"
Images = "~0.24.1"
Interpolations = "~0.13.4"
Plots = "~1.20.1"
PlutoUI = "~0.7.9"
StaticArrays = "~1.2.12"
TestImages = "~1.6.1"
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

[[StringDistances]]
deps = ["Distances"]
git-tree-sha1 = "a4c05337dfe6c4963253939d2acbdfa5946e8e31"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.10.0"

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

[[TestImages]]
deps = ["AxisArrays", "ColorTypes", "FileIO", "OffsetArrays", "Pkg", "StringDistances"]
git-tree-sha1 = "db28237376a6b7ae9c9fe05880ece0ab8bb90b75"
uuid = "5e47fb64-e119-507b-a336-dd2b206d9990"
version = "1.6.1"

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
# ╟─0a05e850-cb9f-11eb-39cb-3d183bb8d5a9
# ╟─daac555d-0d99-4cc2-9ee1-b5317d52aad9
# ╟─c45c4844-801f-43f5-b62c-ee7b30439b91
# ╠═7b2079a5-70bd-4efa-9317-c64f062eaae7
# ╟─c8634d32-c113-4a42-954e-1ab5340562e5
# ╟─d63b3c97-8ed0-4cd4-b632-dd32d3180d17
# ╠═1defdc63-e4b3-4ec6-8369-7cd67e957bd4
# ╟─2474a164-147d-48dd-8f77-88e082756d0f
# ╠═3641ea76-46bb-409b-ad7f-a29d955127d4
# ╠═fafc1904-e1f9-4912-ba4e-c27117ba5677
# ╠═713299aa-54e1-4462-ae59-49605e6e0e90
# ╠═bb3748af-d88e-4a81-bec5-75352c617f7a
# ╟─32f5495e-0b87-47aa-9fd5-34e18a489e28
# ╠═def23802-a9be-4f25-a06b-24eed090f2ab
# ╠═52c51b6b-29a8-44b2-8638-821462d5264c
# ╠═f90fba79-795b-4285-8b19-444c63a9a34c
# ╠═f53226ee-88b7-48bc-b96f-5c98cb91b179
# ╠═222b0e84-cc4a-4fbb-8b89-2f5e24ee811b
# ╠═79b1efb8-3fea-4e86-92da-517cdac28773
# ╠═72db5304-0ef0-4d56-9424-2465868f6863
# ╠═8b54df1e-a7fd-4da4-97ed-90349cd27e84
# ╠═a9426949-cf67-4415-923e-318663e4a753
# ╠═ad1b44a6-65b9-4a2a-b32b-d9f83d45cd3b
# ╠═4712f8dd-5a2f-4a5f-81c3-e275f05ce97a
# ╠═ac45accd-da73-4c7e-8daa-398cc15c2caf
# ╠═69537a5a-f0bd-40d7-a681-9a908cb4c883
# ╟─95f5eac2-ff17-4eaa-b8e6-b16c13b18b8d
# ╠═330b067f-99b6-453b-8ef8-6d6cfa29c541
# ╠═ed035485-6c4d-4b6e-ab69-4d5010b5399f
# ╠═cc0c6b8b-2552-40ac-a6d8-e0e73d94a631
# ╠═ffc6fd00-90a8-4683-9a2a-0f08e6979b8d
# ╠═be219366-ae51-4a34-bf94-96e4fe942dfc
# ╠═63ac8a21-1a07-4708-b54c-f9efb279414a
# ╠═5ee06623-5d13-4a5e-b72e-0fc7c983883d
# ╠═95b4b482-dd40-420a-a9f2-9a0f377f9db8
# ╠═7da385e0-c032-4110-926c-44a2b657a2d3
# ╠═bf4260a4-ca5d-418b-985b-515898817320
# ╠═47017d5e-aad4-41f4-b9c8-533721784646
# ╠═5a5b2db1-ba56-47c2-b5ce-f7647d10016e
# ╠═d3c1e945-17d9-4a07-8805-242c898ea2d6
# ╠═8954bb72-0421-4073-9a67-4ef12259b760
# ╟─3d83ac25-23d2-48d8-bdcd-5b76e4210a21
# ╠═b59b26a9-62b2-4a73-aa98-933d42a9d2ca
# ╠═97af0d61-0c4b-4d6b-8fc4-7ec2c067d5a9
# ╟─8643dfe4-16d1-4f3e-872f-de97b07e1944
# ╠═349db48e-c1e0-42a2-838d-db5267cadc3d
# ╟─505a5eac-f0be-4969-889b-97f5ffc406da
# ╠═1b6ffe16-7b63-41c1-84c8-87aabe51badc
# ╟─268cfedb-e3a2-4bdf-9173-5395bb618b37
# ╠═039d1246-2189-42d7-859b-1f0358a3ed3c
# ╠═85a68539-044e-4f8d-a065-7e747bde4c83
# ╠═e1c506e9-bc39-4142-abec-5b7322528e70
# ╟─70c3ea70-bace-47eb-84cf-b246ab300b23
# ╠═f0259140-3167-4ad8-a1ae-f9c8d0d2d77c
# ╠═05c9f15b-bfb3-43a5-ad6c-0a14f127b96d
# ╟─754fddfe-2f2c-448c-9d8c-dec5d994408f
# ╠═f1636d30-8527-467a-99b6-6eac97c59c61
# ╟─6103db78-7b43-47dd-a1dd-4637c38b898b
# ╠═5a9d52bf-11b0-40ca-946c-ed7248fbbf20
# ╟─3f60a50a-aaab-401b-ae81-cacc347fc947
# ╠═177870cf-677c-45e2-972a-d56b8ced29f0
# ╟─7bb1bd36-6a51-4a41-b794-ed49ffeefef6
# ╟─1005e439-e51e-4051-8dd8-627aff03dc17
# ╠═fb31605e-fc08-4ec9-8872-cf47020b9701
# ╠═518208c6-a179-40bf-819d-162871b2df71
# ╟─2891c2f0-4a1f-4cad-b48e-b40e4c33b7c6
# ╠═d7e8900e-64b1-4866-94bd-786b3af99d8d
# ╟─d5774ec1-87ad-47d7-a1df-ba4c2ac4cbe2
# ╟─086f76c4-5d9a-47d9-b3d2-1ae168e24a6c
# ╟─17384aa0-7e76-44b3-931e-38099bd4ff6d
# ╠═d9113067-8787-4a18-a5fc-9011a44a2173
# ╟─1c94f4c3-38e7-48a1-8b5f-e15a821b0a4e
# ╠═9a925811-bb2e-4b30-8521-a04d7b411820
# ╟─bd915961-5602-465c-9c99-0623481a9272
# ╠═0c8e29c3-d896-48db-986b-8bfc635b17be
# ╟─93e518f1-47fe-48d8-990a-78eca8f2d4c3
# ╠═e456f2fc-cae5-4c9a-91d2-b3184561606d
# ╟─e4021a39-7e9f-479b-9d69-95447c6cc9dd
# ╟─024e2a32-d4f2-4114-8968-bb7e31a9c8fd
# ╟─f16510d8-3a13-4881-b83f-c41668f96c4d
# ╠═4c6d074a-6564-4a45-bcf3-fb417e4d2ba1
# ╟─1f09d825-e884-415d-a4c5-8ad62938c0ff
# ╟─5a4ca684-0375-4a23-b480-b8ab4e2dc26e
# ╠═34590bcf-5804-4e96-b869-3f9709475b43
# ╟─8ba9d6ae-ad53-4191-b710-74549e039ab7
# ╠═954d43cd-71f1-44b8-b073-ade1e74cdddb
# ╟─960c07a7-9f4e-4a75-a1b4-e8bd27968312
# ╟─483c2f13-53b4-4149-b517-91e25e9ce32f
# ╠═65335b08-0a73-4e6e-9fcd-c734ac2689eb
# ╟─57a8da57-cd62-4f23-823f-6832b0556d95
# ╠═dd14c65f-f75c-4049-8b7d-1aced363128d
# ╠═efbb1823-4544-4a38-8355-00c6ecc0ed15
# ╠═e1c3e6e4-5c85-4b94-a46a-62a5c360d87c
# ╠═de94e237-ac88-4af7-9a4a-edfdf472d05f
# ╠═0af95729-e596-4382-ada7-0093fb909796
# ╟─db3ed199-8efd-4e13-b361-54e1becebf7a
# ╠═fba92f2c-e0a8-4a82-b063-811146ef09eb
# ╠═1c34938a-a05b-4855-9744-e307cea8863b
# ╟─8d21f297-5a7f-4640-bb8a-69b4e436168a
# ╠═981bf301-5ad7-4b16-8a10-b1ce7449ff66
# ╠═97f9aa49-1420-4b05-b0ea-46ffb439ad92
# ╠═bb4f1863-2948-428c-8124-c3927dacbcc4
# ╟─52935cae-f774-4298-be8c-b379ec1c1b7a
# ╠═393ed59c-8cc3-48a8-9fed-ec44e15db10a
# ╠═3754be18-d417-4d26-af28-7e8c1d7ab4cc
# ╠═bb1b79d0-0c35-49c6-8e54-ca01e017a242
# ╟─267b2b47-79a0-4488-9a86-90f86b3b4e2e
# ╠═cab9e98f-5967-4fbc-bc6a-173912c5a05a
# ╠═df6e7b9d-9c76-4447-aab8-2d427f063392
# ╟─6d8c5631-55b0-4e98-b9cb-91bd33a7a32f
# ╟─fd056009-de33-460a-8475-8e93d6e02d46
# ╟─ea1994ed-a14e-4df9-b008-9eeefe69a831
# ╠═4f6c5da3-3d86-46d9-8e4d-c3f254fbd90e
# ╟─644db8e8-9c18-4ea5-be45-17935b807ad9
# ╠═2e96aab5-fc7a-4f2a-a2b4-ed27a9b7004b
# ╟─5e359f41-d768-4cd7-afd6-5b98806ed9a4
# ╠═1ce58807-094b-4576-8fd4-9281ec8bf90d
# ╟─84c7d5f7-2ecc-414e-89b3-1a746c583eee
# ╠═3ba49ed0-86f8-44d7-ad8c-919e18e39b3b
# ╟─d043cadb-d0ac-4570-a669-56b4718a62ec
# ╟─34e2cee3-583c-4f30-bef7-676d30b76935
# ╟─892d5edb-f572-41f4-b328-4dc0a0adf8ed
# ╠═e031b0fd-acc6-4552-93b5-ba6208848c6e
# ╟─b8e78721-fab9-4e10-bcd4-a3e2fed3e4d6
# ╠═34df0824-f264-4493-b7b4-0c9946d03310
# ╟─e596f8c0-a7e7-4e92-99a8-3da11620aeab
# ╟─f976fa97-08c9-4a87-90fd-3d757359a53b
# ╟─c81c323f-3137-46e3-8b54-445a440f1cf9
# ╠═bb5ff4d0-854b-4297-a887-9062ad6c1a9e
# ╠═df78b4cb-25a1-41a5-9dce-251f827bd246
# ╟─d5feba51-64c7-4dfd-97b5-283be7e969dc
# ╟─e6105acc-5fa6-453f-9b8e-c7e31d6834b6
# ╟─3a77a494-d17a-4bcc-b59f-4668c07e31bc
# ╠═5e78fe3d-4c9a-4597-9ca1-b641874e5996
# ╠═dcb663f8-5a49-420b-85ba-17b8d60febcc
# ╠═742d65cb-3196-4ace-8e91-65cb4b208696
# ╠═c26e53eb-cfbb-40df-8f11-67d0bb3add1f
# ╠═45b39cd3-e104-49ca-9a88-3b0ece4edb18
# ╠═4c6f736f-217a-46c5-87d1-3377f9daa953
# ╠═44fb2e5e-4f95-4d08-a1c1-73cda73fca9c
# ╠═7cb01529-b500-4729-8cab-be5985739489
# ╠═6d120b0b-ae51-4874-ae6b-17ed42f1fecf
# ╠═97ea5326-cbf0-4e56-92fb-e692c5867e77
# ╠═6b5368f1-ac22-489b-a95b-d51696472e17
# ╠═c32eaf9d-3939-40ec-a7fb-83b911387591
# ╠═9f01b2fc-1122-449a-92c9-663c734b3eff
# ╠═8e448fd4-6a83-48f0-9345-44322f991a49
# ╟─d33ef724-4bb7-4be5-a9cf-14a928fb2289
# ╠═bbc98009-e757-4936-8251-d57426b8cb9b
# ╠═8425a6ff-b968-4245-b351-face7d874a2b
# ╠═371b82c0-518f-4a23-8d83-9775aefdfb76
# ╠═9da5dc21-db80-4ea1-b54d-d774bd8c94a4
# ╠═226b6612-7f60-44c6-8452-cba9b318b1ca
# ╟─72de7fb2-8288-4bc5-8293-eeed4016563f
# ╠═807854a1-032f-4dd9-8e50-895b92d23322
# ╠═4ce1ccad-36a4-41be-97e6-10fc4586cdad
# ╠═28c4e4ce-bfac-4abd-bd1a-ce936d15c0e6
# ╠═6ce1d16b-479f-4175-9943-fbc611dcee9c
# ╠═de0ba933-75c6-4548-8e95-78bfba8e6d4a
# ╠═d6ed210d-2774-4a16-8f02-2e0391dce749
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
