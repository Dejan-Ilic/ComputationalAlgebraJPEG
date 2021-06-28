### A Pluto.jl notebook ###
# v0.14.8

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

# ╔═╡ b75f84b0-0ecc-4757-be3c-463859a38cc4
begin
	using Pkg
	#["Images", "TestImages", "PlutoUI", "FFTW", "Plots", "StaticArrays"] .|> Pkg.add
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
Let's install and import some packages. Uncomment the third line and press `SHIFT-ENTER` to run the cell. You only need to do this the first time you use this notebook.
"""

# ╔═╡ 27727c11-3fad-46ea-9cc0-10c44d437cf1
md"""Next, we will import the packages. This might take a while to precompile."""

# ╔═╡ c8634d32-c113-4a42-954e-1ab5340562e5
md"""Before we can learn about JPEG, we first have to learn some Julia. It is asumed that you have a background in Python or MATLAB.

In the next few sections, you will learn the basics of Julia through some small examples and interactive exercises.

Be aware that the output of a cell containing code appears ABOVE the cell rather than below."""

# ╔═╡ d63b3c97-8ed0-4cd4-b632-dd32d3180d17
md"""### Basic syntax: *if, for, begin, let*
Let's look at some basic syntax, first if, elseif, else, and &&, or ||:"""

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
Complete the following three exercises on vectorization. Your solutions should be stored in the variables `solution{1,2,3}`. Scroll down to the end of the exercise to see whether your solutions were correct (the notebook checks your solutions in real-time).

The first two are warm-up questions and require no further explaination.
"""

# ╔═╡ 05c9f15b-bfb3-43a5-ad6c-0a14f127b96d
solution1 = 0 #apply f(2,1, .) on test_vector1

# ╔═╡ f0259140-3167-4ad8-a1ae-f9c8d0d2d77c
solution2 = 0 #apply sin element-wise on test_vector2

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
solution3 = 0 #replace this dummy value with the asked value

# ╔═╡ 7bb1bd36-6a51-4a41-b794-ed49ffeefef6
let
	sol3(a, b) = a.^sqrt(abs(b))

	md"""
	Check solutions:
	1) $(solution1 == f.(2,1,test_vector1) ? :correct : :incorrect)
	2) $(solution2 == sin.(test_vector2) ? :correct : :incorrect)
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

#### Exercise
Write a function that receives an Array containing numerical values, and replaces all negative values with zero."""

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
**Remark:** printing/showing output is a bit inconvenient in Pluto; all printing should be wrapped within the following block:

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
	end
end

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
  
JPEG converts color to ``YC_bC_r`` where ``Y`` can be seen as the average intensity and, ``C_b`` and ``C_r`` as the blue and red shift. This is a linear, invertible transform which is probably why it was chosen over others.
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


# ╔═╡ 5e78fe3d-4c9a-4597-9ca1-b641874e5996
#make a 8x8 base image
baseimg(k) = [8i+j == k ? 1.0 : 0.0 for i=0:7, j=0:7]

# ╔═╡ dcb663f8-5a49-420b-85ba-17b8d60febcc
#Visualize it
Gray.(baseimg(5))

# ╔═╡ 742d65cb-3196-4ace-8e91-65cb4b208696
#turn baseimg into a function

# ╔═╡ c26e53eb-cfbb-40df-8f11-67d0bb3add1f
#now make stdbase list
[Gray.(baseimg(k)) for k=0:63]

# ╔═╡ 45b39cd3-e104-49ca-9a88-3b0ece4edb18
#now make stdbase matrix
[Gray.(baseimg(8i + j)) for i=0:7, j=0:7]

# ╔═╡ 4c6f736f-217a-46c5-87d1-3377f9daa953
#make dct base image function
dctimg(k) = idct(baseimg(k))

# ╔═╡ 44fb2e5e-4f95-4d08-a1c1-73cda73fca9c
#test it
dctimg(0)

# ╔═╡ 7cb01529-b500-4729-8cab-be5985739489
#define rescale function
function rescale(U)
	m = minimum(U)
	M = maximum(U)
	
	return Gray.((U .- m)/(M-m))
end

# ╔═╡ 6d120b0b-ae51-4874-ae6b-17ed42f1fecf
#test it
rescale(dctimg(2))

# ╔═╡ 97ea5326-cbf0-4e56-92fb-e692c5867e77
#matrix it
[rescale(dctimg(8i + j)) for i=0:7, j=0:7]

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
\sqrt{\frac{\int_0^\infty f(u) du}{\frac{df}{dx}}}
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

# ╔═╡ Cell order:
# ╟─0a05e850-cb9f-11eb-39cb-3d183bb8d5a9
# ╟─daac555d-0d99-4cc2-9ee1-b5317d52aad9
# ╟─c45c4844-801f-43f5-b62c-ee7b30439b91
# ╠═b75f84b0-0ecc-4757-be3c-463859a38cc4
# ╟─27727c11-3fad-46ea-9cc0-10c44d437cf1
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
# ╠═05c9f15b-bfb3-43a5-ad6c-0a14f127b96d
# ╠═f0259140-3167-4ad8-a1ae-f9c8d0d2d77c
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
# ╠═d5feba51-64c7-4dfd-97b5-283be7e969dc
# ╠═e6105acc-5fa6-453f-9b8e-c7e31d6834b6
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
