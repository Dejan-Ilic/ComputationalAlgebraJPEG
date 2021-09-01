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

# ╔═╡ c83f1947-acdb-4458-b5d2-5b9b75c46544
using Images, TestImages, PlutoUI, Plots, Random

# ╔═╡ 928488a0-0af4-11ec-34a7-23dcf9e45875
md"""
# Computational Algebra JPEG session 

In  this Pluto notebook we will implement the JPEG compression algorithm.
"""

# ╔═╡ 096dca13-677b-44ac-80b1-aae5f9fe0874
md"""
## JPEG
"""

# ╔═╡ 5d9bbc4f-4931-4323-8409-9d531543f4ac
md"""
### Image representation
"""

# ╔═╡ ce79774e-3273-4133-8cca-4356a531cbba
md"""Throughout this course, code is often hidden when only the output is important to the reader. The interested reader is invited to examine the hidden code outside of class.

Let's load our test image for today"""

# ╔═╡ a490cfc9-8b9b-404b-aa98-829fc81aeeb6
mandrill = testimage("mandrill")

# ╔═╡ 66c3de93-0999-47d5-a385-42d1f676b9c7
md"""In Julia, images are 2D matrices of RGB objects. To see the underlying 3 x $(size(mandrill,1)) x $(size(mandrill,2)) 3D matrix, we can use the `channelview` function (scroll sideways to see all three "pages" of the 3D matrix).

Its output can be interpreted as 3 _pages_ of size $(size(mandrill,1)) x $(size(mandrill,2)). Note that pixels have values between 0 (black) and 1 (white). In MATLAB, depending on the data type (integer resp. float) intensity values range between 0 and 255, resp. 0 and 1. In Julia they always range between 0 and 1 because integer intensities `i` are interpreted as `i/255`.
"""

# ╔═╡ 8e5edc62-d274-4582-8b90-e56ddd89cbf8
channelview(mandrill)[1, :, :], channelview(mandrill)[2, :, :], channelview(mandrill)[3, :, :]

# ╔═╡ 20d1eeb1-d77a-46df-9022-2ebe346d3cbc
md"Multiplying the matrices with 255 (and casting them to the `Int` type) results in a more traditional representation of the image"

# ╔═╡ 456f6bba-a6bc-4f79-aca5-75895ea42fc8
Int.(255*channelview(mandrill)[1, :, :]), Int.(255*channelview(mandrill)[2, :, :]),  Int.(255*channelview(mandrill)[3, :, :])

# ╔═╡ 7db01c1a-a097-40ce-98fd-8d17f663c147
md"""Let's tear the pages apart and store them in regular 2D matrices `R`, `G` and `B`."""

# ╔═╡ 6910beed-be47-4ad0-9eab-61b353abf5db
begin
	R = channelview(mandrill)[1, :, :]
	G = channelview(mandrill)[2, :, :]
	B = channelview(mandrill)[3, :, :]
end #output will only show B

# ╔═╡ 33dd8194-8130-4f1a-86ae-1f8520f04924
md"""Using some library functions, we can stack the R matrix on top of 2 zero arrays, which dims out the G and B channel. We do the same with the G and B channel."""

# ╔═╡ dc99a6fb-fdf6-488e-b538-dda2b92ef87a
hcat(colorview(RGB, StackedView(R, zeroarray, zeroarray)), colorview(RGB, StackedView(zeroarray, G, zeroarray)), colorview(RGB, StackedView(zeroarray, zeroarray, B)))

# ╔═╡ 2133a02a-2456-4ef5-8254-ef41b7028e67
md"The following sliders control the proportion, `0% - 100%`, of the respective channels that is let through in the next example.

Red: $(@bind R_intensity Slider(LinRange(0,1,101), 1, true))

Green: $(@bind G_intensity Slider(LinRange(0,1,101), 1, true))

Blue: $(@bind B_intensity Slider(LinRange(0,1,101), 1, true))
"

# ╔═╡ 33b02f2a-6111-4113-8c9f-f64321b70eb6
colorview(RGB, R_intensity * R, G_intensity * G, B_intensity * B)

# ╔═╡ 2057cbf7-a136-4c17-8c5e-026844dec7b9
md"""Being mathematicians (or computer scientists? can they also take this course?) we of course immediately realize that an RGB image is just a stack of 3 grayscale images! This means we can develop our compression techniques on a single channel."""

# ╔═╡ c80d0829-05f2-4419-8e38-2a3bfc77878a
mandrill_gray = Gray.(mandrill) #julia vectorize syntax

# ╔═╡ c9b253a3-2942-4311-b1b3-3d032e4c376b
md"""**Remark:** the ``RGB`` *color space* is just one way to store color coordinates. If you think of RGB as analogous to Cartesian coordinates, then there also exist color space which are analogous to polar coordinates. 
  
The ``HSI`` (hue - saturation - insentity) color space separates color information (hue: what color; and saturation: low: pastel and high: cartoon) from intensity information. In this sense HSI is very much like (θ, ϕ, ρ). 
  
Such representations that separate color information from intensity information are commonly used in image compression as the human eye is much more sensitive to intensity information than to color information. This means that greater compression without visual loss can be achieved by heavily compressing the channels that contain color information while leaving the intensity information more in tact.
  
JPEG converts color to ``YC_bC_r`` where ``Y`` can be seen as the average intensity and, ``C_b`` and ``C_r`` as the blue and red shift. This is a linear transform which is probably why it was chosen over others.
"""

# ╔═╡ 6cec67b9-adc2-4015-b99c-35c91477aaa2
mandrill_HSI = convert.(HSI, mandrill);

# ╔═╡ afb1ebc3-cfec-47ad-b42e-c97559b1e9f1
md"
Control `S` in `HUE` image:
$(@bind HUE_s Slider(LinRange(0,1,100), 100, true))

Control `H` in `SAT` image: $(@bind SAT_s Slider(0:360))
Control `I` in `SAT` image: $(@bind SAT_i Slider(LinRange(0,1,100), 100, true))

"

# ╔═╡ 65dd7c05-4338-480d-8b8d-9a60af44b1ff
let
	H = channelview(mandrill_HSI)[1, :, :]
	S = channelview(mandrill_HSI)[2, :, :]
	I = channelview(mandrill_HSI)[3, :, :]
	
	onearray = ones(size(H))
	
	hcat(colorview(HSI, StackedView(H, HUE_s*onearray, 0.5 * onearray)), colorview(HSI, StackedView(SAT_s*onearray, S, SAT_i*onearray)), colorview(HSI, StackedView(zeroarray, zeroarray, I)))
	
end

# ╔═╡ 8ba903f4-ce62-422c-83db-6076a6c6b932
md"**Exercise:** try to make sliders that modify values `α`, `β` and `γ`. Then display

`colorview(HSI, StackedView(α * H, β * S, γ * I))`

in the next cell. Experiment with different ranges."

# ╔═╡ 297bba22-b28a-4f82-baf9-c472a985f737
#code for sliders

# ╔═╡ 8f967b5a-f29e-444d-8df4-3c7660d4f591
#code for displaying images

# ╔═╡ 5567f616-76fb-4224-bb9d-df92738637a6
md"## JPEG algorithm
### Overview"

# ╔═╡ 7f07e91d-c7c9-46d9-8631-128b3cd6cd16
md"The JPEG *encoding* algorithm consists of the following steps:
1. Forward Discrete Cosine Transform (FDCT)
2. Quantization
3. Huffman Encoding

The JPEG *decoding* algorithm follows those steps in the opposite direction
1. Huffman Decoding
2. Dequantization
3. Inverse Discrete Cosine Transform (IDCT)"

# ╔═╡ eec317e1-94f0-4e3a-8cdf-341b8f47a712
md"### Discrete cosine transform
#### Fourier cosine transform
Repeat that the Fourier transform of a function ``x(t) : \mathbb{R} \to \mathbb{R}`` is given by

```math
\mathcal{F}(x(t))(\omega) = X(\omega) = \left(\frac{1}{2\pi}\right)^{1/2} \int_{-\infty}^{+\infty} x(t) e^{-i\omega t} \mathrm{d}t
```
and its inverse


```math
\mathcal{F}^{-1}(X(\omega))(t) = x(t) = \left(\frac{1}{2\pi}\right)^{1/2} \int_{-\infty}^{+\infty} X(\omega) e^{i\omega t} \mathrm{d}\omega
```

To derive the DCT, we first derive the (continuous) Fourier cosine transform. Let ``x: \mathbb{R}^+\to \mathbb{R}`` and define

```math
y: \mathbb{R} \to \mathbb{R}: t\mapsto \left\{\begin{array}{ll} x(t) &\text{if } 0 \leq t\\ x(-t) &\text{if } t < 0\end{array}\right.
```

Using Euler's identity, we find that

```math
\begin{align*}
\mathcal{F}(y)(\omega) &= \left(\frac{1}{2\pi}\right)^{1/2} \int_{-\infty}^{+\infty} y(t) e^{-i\omega t} \mathrm{d}t\\
&=\left(\frac{1}{2\pi}\right)^{1/2} \left[\int_{-\infty}^{0} x(-t) e^{-i\omega t} \mathrm{d}t + \int_{0}^{+\infty} x(t) e^{-i\omega t} \mathrm{d}t\right]\\
&=\left(\frac{2}{\pi}\right)^{1/2}\int_{-\infty}^{+\infty} x(t) \cos(\omega t) \mathrm{d}t
\end{align*}
```

This leads us to the definition of the *Fourier cosine transform*
```math
\mathcal{F}_c(x)(\omega) = X_c(\omega) = \left(\frac{2}{\pi}\right)^{1/2}\int_0^\infty x(t) \cos(\omega t) \mathrm{d}t
```
Also note that ``\mathcal{F}_c^{-1} = \mathcal{F}_c``.

"

# ╔═╡ dd8ad5ea-2bae-4e4d-9688-13c8c7cc99ef
md"#### The discrete cosine transform
The integral that defines the Fourier cosine transform multiplies ``x(t)`` with the kernel ``K_c(\omega, t) = \cos(\omega t)``.

We discretize this kernel by chosing intervals ``\Delta t, \Delta f > 0`` such that ``\Delta t \Delta f = N \in \mathbb{N}``. Next, we define ``\omega_m = 2\pi m\Delta f`` and ``t_n = n\Delta t`` where ``m, n = 0, 1,\ldots, N``.

The discrete kernel is thus given by
```math
\begin{align*}
K_c(m, n) &= K_c(\omega_m, t_n)\\
&= \cos(2\pi m\Delta f \cdot n\Delta t)\\
&= \cos\left(\frac{\pi m n}{N}\right)
\end{align*}
```

This is an ``(N+1)\times (N+1)`` matrix ``[M]_{m,n} = K_c(m,n)`` where again ``m, n = 0, 1,\ldots, N``.

That means our discretized integral, which we call the DCT, can be written as a matrix multiplication

```math
\underline{X} = M\underline{x}, \qquad \underline{x} \in \mathbb{R}^{N+1}
```
such that for ``m = 0, \ldots, N`` it holds that
```math
X_m = \sum_{n=0}^N x_n K_c(m,n) = \sum_{n=0}^N x_n\cos\left(\frac{\pi m n}{N}\right)
```

It can be shown that the inverse of ``M``, i.e. the inverse DCT, is equal to the transpose of ``M``.
"

# ╔═╡ a79c0b69-8947-4e59-9f9e-47c0feef7512
md"""
The JPEG standard however uses a different DCT pair, namely DCT-II and DCT-III. DCT-II is called the *forward* DCT and DCT-III is called the *inverse* DCT. 

DCT-II:
```math
[C_N^{II}]_{m,n} = \sqrt{\frac{2}{N}} k_m \cos\left(\frac{m\left(n+\frac{1}{2}\right)\pi}{N}\right)
```
DCT-III:
```math
[C_N^{III}]_{m,n} = \sqrt{\frac{2}{N}} k_n \cos\left(\frac{\left(m+\frac{1}{2}\right)n\pi}{N}\right)
```

where this time ``m = 0, 1, \ldots, N-1`` and 
```math
k_m = \left\{\begin{array}{lLl}
\frac{1}{\sqrt{2}} & \text{if }& m = 0\\
1 & \text{if }& m = 1, 2, \ldots, N-1
\end{array}\right.
```

A sketch of the proof that they are each other's inverses will be given in a subsequent section."""

# ╔═╡ fc78b1b5-344a-48c1-b772-6ff2bf36102d
md"#### Implementing the DCT
As a warm-up to the 2D-DCT, first we will implement the 1D DCT. Let ``N = 8`` and change the `unitvector` function such that it returns a unit vector with a 1 on the ``k``th entry and 0 elsewhere."

# ╔═╡ ff6562fb-e4a6-48ef-9f28-bab52f6b9d1b
const N = 8

# ╔═╡ 66d17414-fb64-41d8-9271-311bf70d727b
function unitvector(k::Int)
	v = zeros(N)
	#exercise: return vector of size N with entry k = 1, entry != k = 0
	
	return v
end

# ╔═╡ 28032d35-b1a2-4cc0-8f6c-6a8b8af45666
begin
	function discreteplot(f::AbstractArray)
		N = length(f)
		x = [floor(i/3) for i=0:3*N-1]
		f2 = [let rem = i%3; if rem==0 0 elseif rem==1 f[1 + (i-1)÷3] else NaN end end for i=0:3*N-1]

		plot(x,f2, line=2, framestyle=:origin, linecolor=:blue, label=nothing, xticks=nothing)
		scatter!(0:N-1, f, color=:blue,     markerstrokewidth = 0, label=nothing, xticks=nothing)
	end
	md"The next cell uses the provided function `discreteplot(::Vector)` to plot the unit vectors you just defined. This allows you to verify your implementation."
end

# ╔═╡ 639da4db-37c8-4705-9331-f359b0d43570
plot([discreteplot(unitvector(k)) for k=1:N]...)

# ╔═╡ ffb97560-da59-4518-a2b3-2c1c499e8ca9
md"Next, we will implement the DCT functions. Although these are just matrix multiplications, wrapping them inside a function provides additional clarity. 

First, define the value ``k_m`` from the DCT equations as a function:"

# ╔═╡ 082a2eab-5c8d-4d67-af92-d0733a4fbda1
function k(m::Int)
	#implement this function correctly
	
	return (m == 0 ? 1/sqrt(2) : 1.0)
end

# ╔═╡ 6447cae8-2f83-42c9-97e1-dc3c1a506624
md"Next, use this `k` function to define the matrices:"

# ╔═╡ ad9ceaa9-83a8-4910-968f-17e69ecc7b31
DCT_II_Matrix = [0 for m=0:N-1, n=0:N-1]

# ╔═╡ 70c04d56-c7c7-45f0-8148-a5b6f228880e
DCT_III_Matrix = [0 for m=0:N-1, n=0:N-1]

# ╔═╡ 382b9046-d722-43d7-9708-355c0d76b7ae
md"For clarity, the matrices are given multiplication-wrappers in the form of the following functions:"

# ╔═╡ 3d49ae24-11b2-46e1-bfcc-96cf4f85cc25
DCT_II(x::Vector) = DCT_II_Matrix * x

# ╔═╡ bc6a83f7-e2ea-4d32-9f02-af61cb24b727
DCT_III(X::Vector) = DCT_III_Matrix * X

# ╔═╡ 121b9243-67d4-49d7-83bb-51e0743635f6
md"Let's test the implementation of our DCT functions on some unit vector. `DCT_III(DCT_II(u))` should be again equal to `u`."

# ╔═╡ 35966491-1b10-4420-b0ad-218f871911c5
begin
	function clean_round(v::AbstractVector)
		[let r = round(Int, vi);
			abs(r - vi) < 1e-14 ? r : vi
		 end for vi in v]
	end
	
	md"The result of the previous cell might look hard to interpret due to machines precision errors like `6.93889e-18`. To make the result easier to interpret, this notebook provides the utility function `clean_round(::Vector)`. Try using it on the result of the above cell."
end

# ╔═╡ 4896169d-1329-4af4-81c5-134e19cb8f25
DCT_III(DCT_II(unitvector(3))) |> clean_round

# ╔═╡ 1ae10f9f-d10e-4a4f-b0fd-65255a1c222d
md"Using the DCT function(s), modify the code that plotted the unit vectors to show the basis vectors of the DCT"

# ╔═╡ fdcef284-cf62-4108-8ccb-ecf29d176aaa
#exercise

# ╔═╡ 0bd56341-c449-48a1-9035-009bf455c55e
md"Next, we will demonstrate how to use the DCT to achieve compression. First, we generate a random vector of length ``N = 8`` and plot it using the `discreteplot` function."

# ╔═╡ 68757d6e-9365-4183-b3e7-40452b224a57
y = rand(N)

# ╔═╡ 1906705f-d30b-41d5-8700-7db810e5c652
discreteplot(y)

# ╔═╡ 61aaf12e-bb83-43e0-8037-ef8ebefbc85c
md"Next, we use the forward DCT, i.e. `DCT-II`, to transform the function to the DCT domain. Then we plot it."

# ╔═╡ 41617f0b-7520-455c-8a56-0240429ecfe1
z = DCT_II(y)

# ╔═╡ edff7fef-3595-449d-9dad-796182181476
discreteplot(z)

# ╔═╡ 79850399-4adb-4bd9-8c7c-0e26aed8773f
md"On the above plot, some coefficients will have much smaller magnitude compared to others. To achieve compression, we can set the smallest entries of `z` to zero. Modify the code below to your specific case."

# ╔═╡ f366a752-0711-441c-8536-03b28b0dbbe5
z_compressed = let
	a = copy(z)
	a[6] = a[3] = a[4] = a[5] = 0 #modify this, leave the other lines
	a
end

# ╔═╡ c10cd6ee-6d00-4166-b263-74ed67eb31b8
md"The next cell plots `z` next to `z_compressed`, which is the compressed signal where you manually set the smallest entries to zero."

# ╔═╡ 1b80d198-e3bd-4dac-a88d-4016e8bae962
plot(discreteplot(z), discreteplot(z_compressed))

# ╔═╡ 55e9b2a6-7955-4adc-9b36-6d51bab1e145
md"Finally, modify the code in the next cell so that it displays the original signal `y` to the signal reconstructed from `z_compressed`."

# ╔═╡ 8fbb97d9-6ec2-4f9e-8bbd-1fd629c1ebff
plot(discreteplot(y), discreteplot( zeros(N) )) #replace the zeros

# ╔═╡ 2120dea5-6640-4bfc-a12b-1ca1ab41e380
md"#### Showing that DCT-II and DCT-III are each other's inverses
To show this result, we follow exercise 13.6 from *Computer Algebra*. Here we'll only give a sketch of the proof.

**Exercise 13.6**: let ``f: \{0,1,\ldots,n-1\}\to\mathbb{R}`` be a discrete signal with period ``n``. Define

```math
g: \mathbb{Z}\to\mathbb{R}: \left\{ \begin{array}{ll}
g(2j) = 0 & \text{for } j \in \{0,1,\ldots, 2n-1\}\\
g(2j+1) = g(4n - 2j -1) = f(j) &\text{for } j\in \{0,1,\ldots, n-1\}
\end{array}\right.
```

Now show the following properties:

1) Show that the DFT of ``g``, ``\widehat{g}``, is a ``\mathbb{R}``-valued function with
    1) ``4n``-periodicity

    2) ``\widehat{g}(k) = \widehat{g}(4n-k) = -\widehat{g}(2n+k) = -\widehat{g}(2n-k)``

2) Show that ``\forall j \in \{0,1,\ldots, n-1\}``

```math
f(j) = g(2j + 1) = \frac{1}{n}\left(\frac{\widehat{g}(0)}{2} + \sum_{k=1}^{n-1}\widehat{g}(k)\cos\left(\frac{\pi k (2j + 1)}{2n}\right)\right)
```

3) Conclude that DCT-II and DCT-III are each other's inverses.

"

# ╔═╡ 1400b47a-b6ab-4709-a3d7-5e41bfa3c56b
md"**Solution 13.6 (1)**:
The ``4n``-periodicity follows from the equation
```math
\begin{align*}
\widehat{g}(k) &= \sum^{4n - 1}_{j=0} g(j) \exp\left(\frac{-2\pi ijk}{4n}\right)\\
&= \ldots\\
&= 2\sum_{j=0}^{n-1} f(j) \cos\left(\frac{\pi k(2j + 1)}{2n}\right)
\end{align*}
```
The other properties follow too from the previous equation and from special properties of the cosine function.

"

# ╔═╡ 481df058-2d6e-4a63-9367-c69d06e55b1d
md"**Solution 13.6 (2)**:
Set ``\omega = \exp\left(\frac{2\pi i}{4n}\right)``, then
```math
\begin{align*}
4nf(j) &= 4ng(2j+1)\\
&= \ldots \\
&= \sum_{k=0}^{4n-1} \widehat{g}(k)\omega^{(2j+1)k}\\
&= \ldots \\
&= 2\widehat{g}(0) + 4 \sum_{k=1}^{n-1} \widehat{g}(k)\cos\left(\frac{2\pi k(2j+1)}{4n}\right)
\end{align*}
```

"

# ╔═╡ 458f00a5-2b04-4e95-8128-fcf2d1c868e7
md"#### 2D DCT
Analogous to 1D signals, 2D signals too can be constructed from basis vectors. For example, ``2\times 2`` images can be constructed from the *standard* basis
```math
\left\{ \left[\begin{array}{cc} 1 & 0\\ 0&0\end{array}\right], \left[\begin{array}{cc} 0 & 1\\ 0&0\end{array}\right],\left[\begin{array}{cc} 0 & 0\\ 1&0\end{array}\right],\left[\begin{array}{cc} 0 & 0\\ 0&1\end{array}\right] \right\}
```
The JPEG standard uses the same idea we previously illustrated on 1D signals on 2D signals. It does so by using the the 2D DCT on ``8\times 8`` sub-patches of images, and compressing each individual patch.
"

# ╔═╡ 7f925368-cd99-42cb-ae7c-bc1d4b45aaa6
md"
The forward 2D DCT is given by 
```math
F(u,v) = \frac{1}{4} k_u k_v \sum_{x=0}^7 \sum_{y=0}^7 f(x,y) \cos\left(\frac{(2x+1)u\pi}{16}\right)\cos\left(\frac{(2y+1)v\pi}{16}\right)
```
where ``u,v = 0,1,\ldots,7``.

The inverse 2D DCT is given by
```math
f(x,y) = \frac{1}{4}\sum_{u=0}^7\sum_{v=0}^7 k_u k_v F(u,v) \cos\left(\frac{(2x+1)u\pi}{16}\right)\cos\left(\frac{(2y+1)v\pi}{16}\right)
```
where ``x,y = 0,1,\ldots,7``.

Let's immediately implement these the `fDCT` and the `iDCT`. Keep in mind that Julia Arrays are indexed from 1 to ``n``.
"

# ╔═╡ bea14dbc-22f6-4827-8ef8-430506ada566
function fDCT(f::AbstractMatrix)
	return zeros(N, N) #exercise: replace
end

# ╔═╡ bf5f1e1b-0d1a-45bd-9860-eb693cbdcb37
function iDCT(F::AbstractMatrix)
	return zeros(N, N) #exercise: replace
end

# ╔═╡ 2007667c-0d89-4016-a251-daaa4503b35f
begin
	function showimage(img::AbstractMatrix)
		return Gray.( img ./ 255)
	end
	
	function showmatrix(matr::AbstractMatrix)
		m = minimum(matr)
		M = maximum(matr)
		
		return @. Gray( (matr - m) / (M - m) )
	end
	
	uint8(x::Gray{N0f8})::UInt8 = reinterpret(UInt8, gray(x))
	
	int(x::Gray{N0f8})::Int = convert(Int, uint8(x))
	
	ape = int.(mandrill_gray)
	
	ape_8x8 = ape[100:107, 100:107]
	
	#quantization table:
	Q_table = [
		16 11 10 16 24  40  51  61;
		12 12 14 19 26  58  60  55;
		14 13 16 24 40  57  69  56;
		14 17 22 29 51  87  80  62;
		18 22 37 56 68  109 103 77;
		24 35 55 64 81  104 113 92;
		49 64 78 87 103 121 120 101;
		72 92 95 98 112 100 103 99;
		];

	#Test image from JPEG standard document for verification
	test_snippet = 
	[139 144 149 153 155 155 155 155;
	144 151 153 156 159 156 156 156;
	150 155 160 163 158 156 156 156;
	159 161 162 160 160 159 159 159;
	159 160 161 162 162 155 155 155;
	161 161 161 161 160 157 157 157;
	162 162 161 163 162 157 157 157;
	162 162 161 161 163 158 158 158];
	
md"""In the remainder of this section, we will recreate our results of the 1D case in 2D. In order to free you of the burden of technicalities, this cell  defines some convenience functions and variables behind the scenes. They will be introduced at the appropriate times.
"""
end

# ╔═╡ 09fddae7-3def-4ba4-bce7-bb6aacc47394
md"First, let's create 2D basis functions as we did in the 1D case. For ``8\times 8`` images, the (standard) basis consists of 64 basis images/vectors, numbered 1 through 64. Complete the following function. Note that you can index matrices with a single index. "

# ╔═╡ 06f12618-ae69-4df7-8437-b21970454f47
function basisimage(n::Int)
	u = zeros(N, N)
	#exercise: complete this function
	return u
end

# ╔═╡ bdb9d1f0-fdf0-443d-945f-4ce99ef63ecc
md"The next cell tests your implementation"

# ╔═╡ c288bd95-9f38-4051-a552-2535ba745c92
basisimage(10)

# ╔═╡ 039ff778-b4a2-40db-9a00-737b606ffa9f
md"The `showmatrix` function rescales *arbitrary* matrices to a displayable range. Take for example a `` 4\times 4`` `randn` matrix, which has values ranging from e.g. -3 to +3 (depending on randomness of course):"

# ╔═╡ fee8015c-a1ff-4e88-8ccb-601771c71b7a
randn_test = randn(4,4)

# ╔═╡ 61328db4-9dfb-453b-8644-58885d9f3cf1
showmatrix(randn_test)

# ╔═╡ 21eea844-6779-4c23-8248-325bc46a1499
md"This means you can also use `showmatrix` to display your `basisimage` matrices in a more visually pleazing manner."

# ╔═╡ af4dbb1a-d969-4d5a-b847-969ad72cb081
#exercise: use showmatrix in combination with basisimage

# ╔═╡ 2f809fae-6b70-40b1-b208-16c5a0393621
md"The next cell will visualize `baseimage(1)` to `baseimage(64)` in a grid pattern, allowing you to verify the correctness of your implementation."

# ╔═╡ e21b9f59-515a-4c62-8886-439a55c05836
[showmatrix(basisimage(8*i + j + 1)) for i=0:7, j=0:7]

# ╔═╡ 0fdb8d99-6858-485e-b80a-42ff65288988
md"As an exercise, modify the code used to generate the basisimages above to show the 2D DCT basis just like we did in the 1D case."

# ╔═╡ 57089d2d-bae5-49f0-84cc-ec0bbb61e7e9
md"Before you try the entire grid, try to visualize a single DCT basis image."

# ╔═╡ b5c5abb0-4ece-460d-8bd6-347bc11a4d4a
#single image
10 |> basisimage |> iDCT |> showmatrix

#this is Julia's pipe syntax, alternatively write:
#showmatrix(iDCT(basisimage(10)))

# ╔═╡ ab508749-3643-4bfb-8409-0b23d4225472
md"If that works you can try the entire grid:"

# ╔═╡ e7fb3c5a-bfcc-4656-a277-b311a5b02ad7
#exercise: entire grid (HINT: modify the code from the previous grid)

# ╔═╡ 523a2bb4-f6d2-4497-9aff-1c478f91dccd
md"Let's try to use our DCT functions on an ``8\times 8`` image."

# ╔═╡ d3ff1432-1c8a-475d-8aee-8ab52e7341a9
md"The variable `ape_8x8` contains an ``8\times 8`` subsample of the mandrill image."

# ╔═╡ 16b3e5bc-017e-4bce-b135-9e14a1154b1c
ape_8x8

# ╔═╡ 8958d9b4-346c-4fbc-b162-602f7965a2b0
md"You can also visualize it using the `showimage` function."

# ╔═╡ 74562a77-92f5-4f69-8f9c-082707cc3a2c
showimage(ape_8x8)

# ╔═╡ 2d42558e-7c50-4718-9fd0-7b18fd0fc9e9
md"Now we compute the forward DCT transform of `ape_8x8`"

# ╔═╡ 15691123-3c6d-445a-851b-01d4b2d6db75
F_ape_8x8 = fDCT(ape_8x8)

# ╔═╡ 1130d824-79a7-4ef3-bd54-791f6bb6a617
md"This yields an ``8\times 8`` matrix. Next we set all entries smaller than a certain threshold to zero."

# ╔═╡ 8e0bdab7-c235-49e8-9679-202b5304d652
threshold = 20

# ╔═╡ 00eb242a-942a-447e-ab0f-3cf245e3e7cb
F_ape_8x8_compressed = [abs(F) < threshold ? 0.0 : F for F in F_ape_8x8]

# ╔═╡ 538d3491-5f80-4d33-9777-d4bac41e8bc3
md"We reconstruct the image with the compressed DCT coefficients (and we round to integers)."

# ╔═╡ 651e64e3-aa01-444b-a341-49cbce7e515d
ape_8x8_reconstructed = round.(Int, iDCT(F_ape_8x8_compressed))

# ╔═╡ b2a10067-22cb-4f4a-a6d9-4b7ff46ed762
md"Finally, we visually inspect the images (original: left, reconstructed: right)."

# ╔═╡ 830ef63a-9978-4d8c-a608-2d7b9ef5cf00
[showimage(ape_8x8), showimage(ape_8x8_reconstructed)]

# ╔═╡ d4be2fbb-eb41-4cae-845b-9d036b74548d
md"The JPEG algorithm works in a similar way, except for the thresholding. Instead of thresholding, quantization is used."

# ╔═╡ 1473b473-4298-4f69-a722-c5ba88bdea85
md"#### Quantization
Given DCT coefficients ``F`` (an ``8\times 8`` matrix) and a *quantization table* ``Q``, we compute the quantized version of ``F``, ``F^Q(u,v)``, according to the following formula:

```math
F^Q(u,v) = \left\lfloor\frac{F(u,v)}{Q(u,v)} + \frac{1}{2}\right\rfloor
```

Dequantizing ``F^Q`` is done by a simple multiplication:
```math
F'(u,v) = F^Q(u,v) * Q(u,v)
```

"

# ╔═╡ 3221b21d-f3d1-4bd1-800b-4b71bc006063
md"A quantization table has to be provide by the person encoding the image and stored as meta-data within a JPEG file. Programs such as Photoshop define their own quantization tables. 

In the paper that describes the JPEG standard, the following quantization table, `Q_table`, is used to demonstrate the algorithm:"

# ╔═╡ 84eeb1d1-8b18-4a46-8d16-ea7c0aea7856
Q_table

# ╔═╡ 50b97859-6c25-4f30-8c2f-cc698b7e9965
md"Notice how the low-frequency basis vectors (left upper corner) are quantized less sharply than the high-frequency basis vectors (right lower corner). This is because the human eye is more sensitive to compression/quantization in the low-frequency coefficients.

Let's implement our own `quantize` and `dequantize` functions. You can use `round(Int, x)` to round a number x and convert it to an `Int`. You can use `floor.(Int, X)` to round an entire matrix."

# ╔═╡ e0c2dfc7-6d3b-43fb-857d-39b35006cd33
function quantize(F::AbstractMatrix, Q::AbstractMatrix)
	return F #exercise: implement correctly
end

# ╔═╡ c5f20a8f-b145-45cc-b025-4460cfa8be96
function dequantize(FQ::AbstractMatrix, Q::AbstractMatrix)
	return FQ #exercise: implement correctly
end

# ╔═╡ 2870c406-21e2-4307-a0e4-33213c79a511
md"Instead of thresholding `F_ape_8x8` like we did earlier, let's try to quantize it this time. Store the result in `F_ape_8x8_Q`."

# ╔═╡ bb1edccd-db05-4b21-8079-a73765717937
#quantize F_ape_8x8
F_ape_8x8_Q  = 0

# ╔═╡ 384f7275-00ee-4aec-8880-fe8e04a86a0b
md"Now dequantize `F_ape_8x8_Q` and store the result in `F_ape_8x8_dQ`. Compare it to `F_ape_8x8`, the variable you are trying to compress."

# ╔═╡ 355165c7-f3f3-4f7c-a776-0f5498c0f0fc
#dequantize ape_8x8_Q
F_ape_8x8_dQ = 0

# ╔═╡ d885b64a-a495-4e3c-99be-eb0078cfb0c7
F_ape_8x8

# ╔═╡ 26c65705-46d4-4ca3-b0de-1f1fb6ce9054
md"Then finally, reconstruct the image from `F_ape_8x8_dQ`. (You don't have to round the final result, the `showimage` function takes care of that.)"

# ╔═╡ b5007746-3b3e-4efe-9a1b-7fce33e508cc
[showimage(ape_8x8), showimage(iDCT(F_ape_8x8_dQ))]

# ╔═╡ 8385b715-6a9d-4938-9886-09f9d0e81bf3
md"#### Huffman trees

To compress the quantized DCT coefficients, a Huffman tree is used. Huffman trees will not be explained in this notebook. 

We will not implement the huffman functions here."

# ╔═╡ d2eb6604-5f64-492b-ad86-6446613b091e
function huffman(x) #returns huffman tree
	return x
end

# ╔═╡ 8ff477eb-938f-48c2-84c1-519f741ec142
function dehuffman(huffmantree) #decodes huffman tree and returns image
	return huffmantree
end

# ╔═╡ bb18bcd3-5251-4b17-8e5b-f96c0d667aec
begin
	crappy_pdf_copy(x) = copy(reshape(x, (8,8))')
	jpeg_test = [139
144
149
153
155
155
155
155
144
151
153
156
159
156
156
156
150
155
160
163
158
156
156
156
159
161
162
160
160
159
159
159
159
160
161
162
162
155
155
155
161
161
161
161
160
157
157
157
162
162
161
163
162
157
157
157
162
162
161
161
163
158
158
158] |> crappy_pdf_copy
	
	solution_jpeg_test_fdct = [235.6
-1.0
-12.1
-5.2
2.1
-1.7
-2.7
1.3
-22.6
-17.5
-6.2
-3.2
-2.9
-0.1
0.4
-1.2
-10.9
-9.3
-1.6
1.5
0.2
-0.9
-0.6
-0.1
-7.1
-1.9
0.2
1.5
0.9
-0.1
0
0.3
-0.6
-0.8
1.5
1.6
-0.1
-0.7
0.6
1.3
1.8
-0.2
1.6
-0.3
-0.8
1.5
1.0
-1.0
-1.3
-0.4
-0.3
-1.5
-0.5
1.7
1.1
-0.8
-2.6
1.6
-3.8
-1.8
1.9
1.2
-0.6
-0.4] |> crappy_pdf_copy
	
		solution_jpeg_test_q = [15
0
-1
0
0
0
0
0
-2
-1
0
0
0
0
0
0
-1
-1
0
0
0
0
0
0
-1
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0] |> crappy_pdf_copy
	
	solution_jpeg_test_dq = [240
0
-10
0
0
0
0
0
-24
-12
0
0
0
0
0
0
-14
-13
0
0
0
0
0
0
-14
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0] |> crappy_pdf_copy
	
	solution_jpeg_test_rec = [142
144
147
150
152
153
154
154
149
150
153
155
156
157
156
156
157
158
159
161
161
160
159
158
162
162
163
163
162
160
158
157
162
162
162
162
161
158
156
155
160
161
161
161
160
158
156
154
160
160
161
162
161
160
158
157
160
161
163
164
164
163
161
160] |> crappy_pdf_copy
	

	
	
	md"""#### JPEG on ``8\times 8`` block

Summary:

`img -> img - 128 -> fDCT -> Quantize -> Huffmann -> save `

`load -> de-Huffmann -> Dequantize -> iDCT -> img' + 128 -> img'`

Let's apply this on the ``8\times 8`` `jpeg_test` image. This same patch is also used in the paper that describes the JPEG standard. 
	
	Complete the following cells to execute the JPEG algorithm. The correct (but rounded) outputs are defined behind the scenes so that you can compare them, `solution_jpeg_test_[x]`, with your solution `jpeg_test_[x]`.

"""
end

# ╔═╡ 7ab5d4ef-bbcf-49fa-a7e8-861e26e5c046
jpeg_test

# ╔═╡ 8146e32c-23ef-4b90-816d-6489428d7a99
jpeg_test_fdct = 0

# ╔═╡ 01287455-52df-45e0-803a-e1b525d68a73
jpeg_test_q = 0

# ╔═╡ 341c7ae5-d3e6-4731-857b-dc507883f1a5
jpeg_test_huffman = 0; #keep the ; to suppress output

# ╔═╡ 1b8ecc6b-4648-497d-a10e-45536c38a140
jpeg_test_dehuffman = 0;

# ╔═╡ af556b44-3f25-44be-87b1-36060f40dbbc
jpeg_test_dq = 0

# ╔═╡ adc580f9-d07a-4abf-b4ea-5fc1832dd03d
jpeg_test_rec = 0

# ╔═╡ af260e9a-308a-4c1d-8049-fe5b77c1ae9f
md"""#### JPEG on an entire image
To be able to reuse our functions that operate on ``8\times 8`` subimages, we are provided with the function `apply_on_sub(f::Function, input::Matrix)` which applies the function `f` on all the ``8\times 8`` subimages of the `input` image."""

# ╔═╡ 7e089b1a-3352-4d86-af3f-b6ff9bd09b9f
function apply_on_sub(f::Function, input::Matrix, blocksize::Int = 8)
	output = similar(input, Float64)
	
	for j=1:blocksize:size(input,2) 
		for i=1:blocksize:size(input,1)
			output[i:i+blocksize-1, j:j+blocksize-1] .= 
								f(input[i:i+blocksize-1, j:j+blocksize-1])
		end
	end
	
	return output
end

# ╔═╡ 9158f818-0e05-4460-92f8-92a445f43e56
md"To demonstrate the usage of this function, we define a test image `subimg_test`, consisting of two ``2\times 2`` blocks (instead of two ``8\times 8`` for convenience). We then define the function `sub_func`, which takes a subimage as input and outputs that subimage with the minimum of the subimage added to every entry.

This means the left half will be reduced by 1, while the right half will be increased by 2."

# ╔═╡ 140f464b-15b4-4d7e-a55d-9f8b8c2ad1f8
subimg_test = [1 -1 2 2;
			  -1  1 2 2]

# ╔═╡ a7e7c777-d91c-418a-9ebe-9a173cbc57e6
function sub_func(x::AbstractMatrix)
	m = minimum(x)
	
	return x .+ m
end

# ╔═╡ e3054a7a-96dc-4a96-ba1b-56dc8832a082
apply_on_sub(sub_func, subimg_test, 2)

# ╔═╡ e2e4103d-f00a-4128-a5bd-6f72f6e2b60f
md"We of course want to use this `apply_on_sub` function to reuse our previous functions. Let's go through a full application of the JPEG algorithm."

# ╔═╡ ecc0a85c-564c-477a-84d2-f8be10693779
md"First, pick a quantization table. By default we will just copy `Q_table` from before. You are encouraged to come up with your own quantization tables or to look for some on the internet."

# ╔═╡ 63f2e841-13a2-4bb9-bd4d-904fa9d51011
Q = copy(Q_table);

# ╔═╡ fae18f9e-267b-48c4-880c-728455c5200a
md"Then we begin the algorithm as described in the summary in the previous section."

# ╔═╡ 52f86fa0-d026-4bad-bd21-82ada3387335
ape

# ╔═╡ 208c634a-f8c6-4b17-8d74-79db94b1837e
ape_minus = ape .- 128

# ╔═╡ c8367f24-b389-457d-b490-739443bcc1f9
ape_fdct = apply_on_sub(fDCT, ape_minus)

# ╔═╡ 448894ba-ccc0-4a58-836c-a40d72d19d39
ape_q = apply_on_sub(x -> quantize(x, Q), ape_fdct)

# ╔═╡ fc1ef559-a7bc-4aed-90ff-8b500bcbc44e
ape_huff = apply_on_sub(huffman, ape_q); # == ape_q

# ╔═╡ 046dd696-47f1-448b-8ac9-6a0baa0f0890
#save to disk

# ╔═╡ 62db95a7-72f3-40de-bff6-48a8b33a24ec
#load from disk

# ╔═╡ 39187e75-2ade-4296-8a27-cdd2d4e097c5
ape_dehuff = apply_on_sub(dehuffman, ape_huff); # == ape_q still

# ╔═╡ dfb4f706-3fe2-43bd-9e01-3fba3b0898f9
ape_dq = apply_on_sub(x -> dequantize(x, Q), ape_dehuff)

# ╔═╡ a4cbdb28-ae80-41e7-adbf-8dd58edf9a1e
ape_idct = apply_on_sub(iDCT, ape_dq)

# ╔═╡ 17797b73-fe82-4722-b6ab-0ca7b340ba69
ape_reconstructed = round.(Int, ape_idct .+ 128)

# ╔═╡ 6129b8cb-633d-4179-bf72-3bb7c31706a1
showimage(ape_reconstructed)

# ╔═╡ 15e35d70-56ab-4e02-ac71-2fa78e417982
md"Now try multiplying `Q_table` to increase or decrease the compression rate."

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
TestImages = "5e47fb64-e119-507b-a336-dd2b206d9990"

[compat]
Images = "~0.24.1"
Plots = "~1.20.1"
PlutoUI = "~0.7.9"
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
# ╟─928488a0-0af4-11ec-34a7-23dcf9e45875
# ╟─096dca13-677b-44ac-80b1-aae5f9fe0874
# ╠═c83f1947-acdb-4458-b5d2-5b9b75c46544
# ╟─5d9bbc4f-4931-4323-8409-9d531543f4ac
# ╟─ce79774e-3273-4133-8cca-4356a531cbba
# ╠═a490cfc9-8b9b-404b-aa98-829fc81aeeb6
# ╟─66c3de93-0999-47d5-a385-42d1f676b9c7
# ╠═8e5edc62-d274-4582-8b90-e56ddd89cbf8
# ╟─20d1eeb1-d77a-46df-9022-2ebe346d3cbc
# ╠═456f6bba-a6bc-4f79-aca5-75895ea42fc8
# ╟─7db01c1a-a097-40ce-98fd-8d17f663c147
# ╠═6910beed-be47-4ad0-9eab-61b353abf5db
# ╟─33dd8194-8130-4f1a-86ae-1f8520f04924
# ╠═dc99a6fb-fdf6-488e-b538-dda2b92ef87a
# ╟─2133a02a-2456-4ef5-8254-ef41b7028e67
# ╠═33b02f2a-6111-4113-8c9f-f64321b70eb6
# ╟─2057cbf7-a136-4c17-8c5e-026844dec7b9
# ╠═c80d0829-05f2-4419-8e38-2a3bfc77878a
# ╟─c9b253a3-2942-4311-b1b3-3d032e4c376b
# ╠═6cec67b9-adc2-4015-b99c-35c91477aaa2
# ╟─afb1ebc3-cfec-47ad-b42e-c97559b1e9f1
# ╟─65dd7c05-4338-480d-8b8d-9a60af44b1ff
# ╟─8ba903f4-ce62-422c-83db-6076a6c6b932
# ╠═297bba22-b28a-4f82-baf9-c472a985f737
# ╠═8f967b5a-f29e-444d-8df4-3c7660d4f591
# ╟─5567f616-76fb-4224-bb9d-df92738637a6
# ╟─7f07e91d-c7c9-46d9-8631-128b3cd6cd16
# ╟─eec317e1-94f0-4e3a-8cdf-341b8f47a712
# ╟─dd8ad5ea-2bae-4e4d-9688-13c8c7cc99ef
# ╟─a79c0b69-8947-4e59-9f9e-47c0feef7512
# ╟─fc78b1b5-344a-48c1-b772-6ff2bf36102d
# ╠═ff6562fb-e4a6-48ef-9f28-bab52f6b9d1b
# ╠═66d17414-fb64-41d8-9271-311bf70d727b
# ╟─28032d35-b1a2-4cc0-8f6c-6a8b8af45666
# ╠═639da4db-37c8-4705-9331-f359b0d43570
# ╟─ffb97560-da59-4518-a2b3-2c1c499e8ca9
# ╠═082a2eab-5c8d-4d67-af92-d0733a4fbda1
# ╟─6447cae8-2f83-42c9-97e1-dc3c1a506624
# ╠═ad9ceaa9-83a8-4910-968f-17e69ecc7b31
# ╠═70c04d56-c7c7-45f0-8148-a5b6f228880e
# ╟─382b9046-d722-43d7-9708-355c0d76b7ae
# ╠═3d49ae24-11b2-46e1-bfcc-96cf4f85cc25
# ╠═bc6a83f7-e2ea-4d32-9f02-af61cb24b727
# ╟─121b9243-67d4-49d7-83bb-51e0743635f6
# ╠═4896169d-1329-4af4-81c5-134e19cb8f25
# ╟─35966491-1b10-4420-b0ad-218f871911c5
# ╟─1ae10f9f-d10e-4a4f-b0fd-65255a1c222d
# ╠═fdcef284-cf62-4108-8ccb-ecf29d176aaa
# ╟─0bd56341-c449-48a1-9035-009bf455c55e
# ╠═68757d6e-9365-4183-b3e7-40452b224a57
# ╠═1906705f-d30b-41d5-8700-7db810e5c652
# ╟─61aaf12e-bb83-43e0-8037-ef8ebefbc85c
# ╠═41617f0b-7520-455c-8a56-0240429ecfe1
# ╠═edff7fef-3595-449d-9dad-796182181476
# ╟─79850399-4adb-4bd9-8c7c-0e26aed8773f
# ╠═f366a752-0711-441c-8536-03b28b0dbbe5
# ╟─c10cd6ee-6d00-4166-b263-74ed67eb31b8
# ╠═1b80d198-e3bd-4dac-a88d-4016e8bae962
# ╟─55e9b2a6-7955-4adc-9b36-6d51bab1e145
# ╠═8fbb97d9-6ec2-4f9e-8bbd-1fd629c1ebff
# ╟─2120dea5-6640-4bfc-a12b-1ca1ab41e380
# ╟─1400b47a-b6ab-4709-a3d7-5e41bfa3c56b
# ╟─481df058-2d6e-4a63-9367-c69d06e55b1d
# ╟─458f00a5-2b04-4e95-8128-fcf2d1c868e7
# ╟─7f925368-cd99-42cb-ae7c-bc1d4b45aaa6
# ╠═bea14dbc-22f6-4827-8ef8-430506ada566
# ╠═bf5f1e1b-0d1a-45bd-9860-eb693cbdcb37
# ╟─2007667c-0d89-4016-a251-daaa4503b35f
# ╟─09fddae7-3def-4ba4-bce7-bb6aacc47394
# ╠═06f12618-ae69-4df7-8437-b21970454f47
# ╟─bdb9d1f0-fdf0-443d-945f-4ce99ef63ecc
# ╠═c288bd95-9f38-4051-a552-2535ba745c92
# ╟─039ff778-b4a2-40db-9a00-737b606ffa9f
# ╠═fee8015c-a1ff-4e88-8ccb-601771c71b7a
# ╠═61328db4-9dfb-453b-8644-58885d9f3cf1
# ╟─21eea844-6779-4c23-8248-325bc46a1499
# ╠═af4dbb1a-d969-4d5a-b847-969ad72cb081
# ╟─2f809fae-6b70-40b1-b208-16c5a0393621
# ╠═e21b9f59-515a-4c62-8886-439a55c05836
# ╟─0fdb8d99-6858-485e-b80a-42ff65288988
# ╟─57089d2d-bae5-49f0-84cc-ec0bbb61e7e9
# ╠═b5c5abb0-4ece-460d-8bd6-347bc11a4d4a
# ╟─ab508749-3643-4bfb-8409-0b23d4225472
# ╠═e7fb3c5a-bfcc-4656-a277-b311a5b02ad7
# ╟─523a2bb4-f6d2-4497-9aff-1c478f91dccd
# ╟─d3ff1432-1c8a-475d-8aee-8ab52e7341a9
# ╠═16b3e5bc-017e-4bce-b135-9e14a1154b1c
# ╟─8958d9b4-346c-4fbc-b162-602f7965a2b0
# ╠═74562a77-92f5-4f69-8f9c-082707cc3a2c
# ╟─2d42558e-7c50-4718-9fd0-7b18fd0fc9e9
# ╠═15691123-3c6d-445a-851b-01d4b2d6db75
# ╟─1130d824-79a7-4ef3-bd54-791f6bb6a617
# ╠═8e0bdab7-c235-49e8-9679-202b5304d652
# ╠═00eb242a-942a-447e-ab0f-3cf245e3e7cb
# ╟─538d3491-5f80-4d33-9777-d4bac41e8bc3
# ╠═651e64e3-aa01-444b-a341-49cbce7e515d
# ╟─b2a10067-22cb-4f4a-a6d9-4b7ff46ed762
# ╠═830ef63a-9978-4d8c-a608-2d7b9ef5cf00
# ╟─d4be2fbb-eb41-4cae-845b-9d036b74548d
# ╟─1473b473-4298-4f69-a722-c5ba88bdea85
# ╟─3221b21d-f3d1-4bd1-800b-4b71bc006063
# ╠═84eeb1d1-8b18-4a46-8d16-ea7c0aea7856
# ╟─50b97859-6c25-4f30-8c2f-cc698b7e9965
# ╠═e0c2dfc7-6d3b-43fb-857d-39b35006cd33
# ╠═c5f20a8f-b145-45cc-b025-4460cfa8be96
# ╟─2870c406-21e2-4307-a0e4-33213c79a511
# ╠═bb1edccd-db05-4b21-8079-a73765717937
# ╟─384f7275-00ee-4aec-8880-fe8e04a86a0b
# ╠═355165c7-f3f3-4f7c-a776-0f5498c0f0fc
# ╠═d885b64a-a495-4e3c-99be-eb0078cfb0c7
# ╠═26c65705-46d4-4ca3-b0de-1f1fb6ce9054
# ╠═b5007746-3b3e-4efe-9a1b-7fce33e508cc
# ╟─8385b715-6a9d-4938-9886-09f9d0e81bf3
# ╠═d2eb6604-5f64-492b-ad86-6446613b091e
# ╠═8ff477eb-938f-48c2-84c1-519f741ec142
# ╟─bb18bcd3-5251-4b17-8e5b-f96c0d667aec
# ╠═7ab5d4ef-bbcf-49fa-a7e8-861e26e5c046
# ╠═8146e32c-23ef-4b90-816d-6489428d7a99
# ╠═01287455-52df-45e0-803a-e1b525d68a73
# ╠═341c7ae5-d3e6-4731-857b-dc507883f1a5
# ╠═1b8ecc6b-4648-497d-a10e-45536c38a140
# ╠═af556b44-3f25-44be-87b1-36060f40dbbc
# ╠═adc580f9-d07a-4abf-b4ea-5fc1832dd03d
# ╟─af260e9a-308a-4c1d-8049-fe5b77c1ae9f
# ╠═7e089b1a-3352-4d86-af3f-b6ff9bd09b9f
# ╟─9158f818-0e05-4460-92f8-92a445f43e56
# ╠═140f464b-15b4-4d7e-a55d-9f8b8c2ad1f8
# ╠═a7e7c777-d91c-418a-9ebe-9a173cbc57e6
# ╠═e3054a7a-96dc-4a96-ba1b-56dc8832a082
# ╟─e2e4103d-f00a-4128-a5bd-6f72f6e2b60f
# ╟─ecc0a85c-564c-477a-84d2-f8be10693779
# ╠═63f2e841-13a2-4bb9-bd4d-904fa9d51011
# ╟─fae18f9e-267b-48c4-880c-728455c5200a
# ╠═52f86fa0-d026-4bad-bd21-82ada3387335
# ╠═208c634a-f8c6-4b17-8d74-79db94b1837e
# ╠═c8367f24-b389-457d-b490-739443bcc1f9
# ╠═448894ba-ccc0-4a58-836c-a40d72d19d39
# ╠═fc1ef559-a7bc-4aed-90ff-8b500bcbc44e
# ╠═046dd696-47f1-448b-8ac9-6a0baa0f0890
# ╠═62db95a7-72f3-40de-bff6-48a8b33a24ec
# ╠═39187e75-2ade-4296-8a27-cdd2d4e097c5
# ╠═dfb4f706-3fe2-43bd-9e01-3fba3b0898f9
# ╠═a4cbdb28-ae80-41e7-adbf-8dd58edf9a1e
# ╠═17797b73-fe82-4722-b6ab-0ca7b340ba69
# ╠═6129b8cb-633d-4179-bf72-3bb7c31706a1
# ╟─15e35d70-56ab-4e02-ac71-2fa78e417982
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
