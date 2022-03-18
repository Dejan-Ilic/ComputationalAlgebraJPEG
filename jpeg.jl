### A Pluto.jl notebook ###
# v0.18.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ c83f1947-acdb-4458-b5d2-5b9b75c46544
using Images, TestImages, PlutoUI, Plots, Random, Kroki

# ╔═╡ 928488a0-0af4-11ec-34a7-23dcf9e45875
md"""
# Computer Algebra JPEG session 

In  this Pluto notebook we will implement the JPEG compression algorithm.
"""

# ╔═╡ 70cdd2c1-9f7b-4421-8ad4-8e5c5ca56e42
TableOfContents("Table of Contents", true, 4, true)

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

Red: $(@bind R_intensity Slider(LinRange(0,1,101), 1.0, true))

Green: $(@bind G_intensity Slider(LinRange(0,1,101), 1.0, true))

Blue: $(@bind B_intensity Slider(LinRange(0,1,101), 1.0, true))
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
$(@bind HUE_s Slider(LinRange(0,1,100), 1.0, true))

Control `H` in `SAT` image: $(@bind SAT_s Slider(0:360))
Control `I` in `SAT` image: $(@bind SAT_i Slider(LinRange(0,1,101), 1.0, true))

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

in the next cell. Experiment with different ranges. You can copy and modify the code from the other sliders."

# ╔═╡ 297bba22-b28a-4f82-baf9-c472a985f737
#put the sliders here (or put 1 slider in this cell and make two additional cells for the β and γ sliders)

# ╔═╡ cd31de7a-75ef-4722-b180-e78b58448231
md"""
!!! hint "Hint for the sliders"
	To show a slider and bind it to a variable α, you can use `@bind α Slider(LinRange(0,1,101))`. This means that α varies from 0 to 1 in 101 steps.
"""

# ╔═╡ 8f967b5a-f29e-444d-8df4-3c7660d4f591
#display the image

# ╔═╡ 5b6e5cd8-8bab-4687-a7e2-6a348a3634b7
md"""
!!! hint "Hint for the display of the image"

	Put the following statements inside a `let` block


	```H = channelview(mandrill_HSI)[1, :, :]```

	`S = channelview(mandrill_HSI)[2, :, :]`

	```I = channelview(mandrill_HSI)[3, :, :]```

	`colorview(HSI, StackedView(α * H, β * S, γ * I))`

	
"""


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
	#exercise: return vector of size N where the kth element is 1 and the others 0

	return v
end

# ╔═╡ 8a8fb63f-2893-4110-af62-ed56ccb7693f
md"""
!!! hint
	add `v[k] = 1.0` below the initialization of `v` inside the `unitvector` function.
"""

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
	
	return 0.0
end

# ╔═╡ fce789f4-724b-4f48-81a4-bd77b9005e60
md"""
!!! hint
	You can return `(m == 0 ? 1/sqrt(2) : 1.0)`.
	"""

# ╔═╡ 6447cae8-2f83-42c9-97e1-dc3c1a506624
md"Next, use this `k` function to define the matrices:"

# ╔═╡ ad9ceaa9-83a8-4910-968f-17e69ecc7b31
DCT_II_Matrix = [0.0 for m=0:N-1, n=0:N-1]

# ╔═╡ d7815fde-1073-461e-baad-3110937f5c9e
md"""
!!! hint
	In `DCT_II_Matrix` replace `[0 ...` with `[sqrt(2/N)*k(m)*cos( (m*(n+0.5)*π) / N) ...`
		"""

# ╔═╡ 70c04d56-c7c7-45f0-8148-a5b6f228880e
DCT_III_Matrix = [0.0 for m=0:N-1, n=0:N-1]

# ╔═╡ f27c2860-8798-4715-b6e7-dc8414fa65e3
md"""
!!! hint
	In `DCT_III_Matrix` replace `[0 ...` with `[sqrt(2/N)*k(n)*cos( (n*(m+0.5)*π) / N) ...`
		"""

# ╔═╡ 382b9046-d722-43d7-9708-355c0d76b7ae
md"For clarity, the matrices are given multiplication-wrappers in the form of the following functions:"

# ╔═╡ 3d49ae24-11b2-46e1-bfcc-96cf4f85cc25
DCT_II(x::Vector) = DCT_II_Matrix * x

# ╔═╡ bc6a83f7-e2ea-4d32-9f02-af61cb24b727
DCT_III(X::Vector) = DCT_III_Matrix * X

# ╔═╡ 121b9243-67d4-49d7-83bb-51e0743635f6
md"Let's test the implementation of our DCT functions on some unit vector. `DCT_III(DCT_II(u))` should be again equal to `u` (ignoring numerical errors)."

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
DCT_III(DCT_II(unitvector(4))) |> clean_round

# ╔═╡ 1ae10f9f-d10e-4a4f-b0fd-65255a1c222d
md"Using the DCT function(s), modify the code that plotted the unit vectors to show the basis vectors of the DCT"

# ╔═╡ fdcef284-cf62-4108-8ccb-ecf29d176aaa
#exercise

# ╔═╡ 2d382a94-560e-4aa7-86bb-53f0d7d34859
md"
!!! hint
	You can copy `plot([discreteplot(unitvector(k)) for k=1:N]...)` and replace `unitvector(k)` with `DCT_III(unitvector(k))`. This takes the inverse DCT of the kth unitvector, which corresponds with the kth basis vector of the DCT.
"

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
plot(discreteplot(y), discreteplot(zeros(N))) #replace the zeros

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

Let's immediately implement these the `fDCT` and the `iDCT`. Keep in mind that Julia Arrays are indexed from 1 to ``n``. Also keep in mind that we index a matrix as `A[row, col]`, where `row` is the ``y``-coordinate of a pixel and `col` the ``x``-coordinate. 

These two remarks combined mean that we would write `f(x,y)` as `f[y+1, x+1]` if `f` were a matrix instead of a function. Likewise, we write `F(u,v)` as `f[v+1, u+1]`.
"

# ╔═╡ bea14dbc-22f6-4827-8ef8-430506ada566
function fDCT(f::AbstractMatrix)
	s(u, v) = sum(0.0 for y=0:N-1, x=0:N-1) #change the 0.0 to the correct value
	return [s(u, v) for v=0:N-1, u=0:N-1]
end

# ╔═╡ 29d0df00-c037-4dfa-be6a-ac1bacb24dfb
md"
!!! hint

	`return [1/4 * k(u) * k(v) * sum(f[y+1, x+1] * cos( ((2x+1)*u*π)/16) * cos( ((2y+1)*v*π)/16) for y=0:N-1, x=0:N-1) for v=0:N-1, u=0:N-1]`
"

# ╔═╡ bf5f1e1b-0d1a-45bd-9860-eb693cbdcb37
function iDCT(F::AbstractMatrix)
	S(x, y) = sum(0.0 for v=0:N-1, u=0:N-1) #change the 0.0 to the correct value
	return [S(x, y) for  y=0:N-1, x=0:N-1]
end

# ╔═╡ 7867fe0f-98d6-48e8-843d-3524c48c4507
md"
!!! hint
	`return [1/4 * sum(k(u)*k(v)*F[v+1, u+1]*cos(((2x+1)*u*π)/16)*cos( ((2y+1)*v*π)/16 for v=0:N-1, u=0:N-1) for y=0:N-1, x=0:N-1]`
"

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
	#complete this function
	return u
end

# ╔═╡ b50b9add-0ab2-475c-88ac-46650aa48e8d
md"!!! hint
	Under the definition of `u` you can add `u[n] = 1.0`.
	"

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

# ╔═╡ 3f9acd0e-8910-4d60-a5fe-14598063de11
md"!!! hint
	`showmatrix(basisimage(n))` where `n` is any number from 1 to 64.
"

# ╔═╡ 2f809fae-6b70-40b1-b208-16c5a0393621
md"The next cell will visualize `baseimage(1)` to `baseimage(64)` in a grid pattern, allowing you to verify the correctness of your implementation."

# ╔═╡ e21b9f59-515a-4c62-8886-439a55c05836
[showmatrix(basisimage(i + 8j + 1)) for i=0:7, j=0:7]

# ╔═╡ 0fdb8d99-6858-485e-b80a-42ff65288988
md"As an exercise, modify the code used to generate the basisimages above to show the 2D DCT basis just like we did in the 1D case."

# ╔═╡ 57089d2d-bae5-49f0-84cc-ec0bbb61e7e9
md"Before you try the entire grid, the next cell shows you how to visualize a single DCT basis image."

# ╔═╡ b5c5abb0-4ece-460d-8bd6-347bc11a4d4a
#single image
10 |> basisimage |> iDCT |> showmatrix

#this is Julia's pipe syntax, alternatively write:

#showmatrix(iDCT(basisimage(10)))

# ╔═╡ ab508749-3643-4bfb-8409-0b23d4225472
md"Now try the entire grid:"

# ╔═╡ e7fb3c5a-bfcc-4656-a277-b311a5b02ad7
#exercise: show a grid of DCT basis images. This should look like
#https://upload.wikimedia.org/wikipedia/commons/2/23/Dctjpeg.png
#but without the superimposed red lines

# ╔═╡ a0bd7604-c8a0-4373-b286-faf004de6c17
md"!!! hint
	`[showmatrix(iDCT(basisimage(i + 8j + 1))) for i=0:7, j=0:7]`
"

# ╔═╡ 523a2bb4-f6d2-4497-9aff-1c478f91dccd
md"Let's try to use our DCT functions on an ``8\times 8`` image."

# ╔═╡ d3ff1432-1c8a-475d-8aee-8ab52e7341a9
md"The variable `ape_8x8` contains an ``8\times 8`` patch of the mandrill image."

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
md"The two images should look alike. This indicates the DCT components can be compressed quite a bit. The JPEG compression algorithm exploits this, but instead of thresholding, it uses quantization."

# ╔═╡ 1473b473-4298-4f69-a722-c5ba88bdea85
md"
### Further compression techniques
#### Quantization
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
	return F #exercise: complete this function
end

# ╔═╡ 7e609a2d-8903-4717-b180-d64994fb3eb0
md"""!!! hint
	`return @. floor(Int, F/Q + 0.5)` or `return floor.(Int, F./Q .+ 0.5)` without the convenience macro `.@`.
"""
	

# ╔═╡ c5f20a8f-b145-45cc-b025-4460cfa8be96
function dequantize(FQ::AbstractMatrix, Q::AbstractMatrix)
	return FQ #exercise: complete this function
end

# ╔═╡ 9fdb6840-1e98-4905-91ed-db666dd5f09f
md"!!! hint
	`return FQ .* Q`
"

# ╔═╡ 2870c406-21e2-4307-a0e4-33213c79a511
md"Instead of thresholding `F_ape_8x8` like we did earlier, let's try to quantize it this time. Store the result in `F_ape_8x8_Q`."

# ╔═╡ bb1edccd-db05-4b21-8079-a73765717937
#quantize F_ape_8x8
F_ape_8x8_Q  = zeros(N,N) #replace the zeros

# ╔═╡ 604816cb-dc08-48c3-bfe8-cd88c159999d
md"!!! hint
	`quantize(F_ape_8x8, Q_table)`
"

# ╔═╡ cbde8c90-e06c-4605-9fcc-e07b737f10a1
md"The resulting `F_ape_8x8` is what will get stored using lossless compression"

# ╔═╡ 384f7275-00ee-4aec-8880-fe8e04a86a0b
md"Now to reconstruct the image from the compressed `F_ape_8x8_Q`, we first dequantize `F_ape_8x8_Q` and store the result in `F_ape_8x8_dQ`. "

# ╔═╡ 355165c7-f3f3-4f7c-a776-0f5498c0f0fc
#dequantize F_ape_8x8_Q
F_ape_8x8_dQ = zeros(N,N) #replace the zeros

# ╔═╡ b90dc81c-77d4-4e11-be7f-66bc39f3539e
md"!!! hint
	`dequantize(F_ape_8x8_Q, Q_table)`
"

# ╔═╡ 69222397-6c1a-4bd6-a883-d36584deccc6
md"Now compare `F_ape_8x8_dQ` to `F_ape_8x8`, its uncompressed/unquantized version."

# ╔═╡ 3892a59d-4e82-47eb-8ef1-3befd46e7ba0
round.(Int, F_ape_8x8)

# ╔═╡ 26c65705-46d4-4ca3-b0de-1f1fb6ce9054
md"Visually comparing matrices that contain frequency components might be a bit too abstract. A more interesting thing to visualize is the reconstructed image. Try to reconstruct the original image from `F_ape_8x8_dQ`. (You don't have to round the final result, the `showimage` function takes care of that.)"

# ╔═╡ fadb1828-fcb3-4207-92fe-c88a75964644
ape_8x8_dQ_reconstructed = zeros(N,N) #replace the zeros

# ╔═╡ a50bf599-dcc2-4560-b276-50caa116adfc
md"""!!! hint
	You can reconstruct the ape from the dequantized DCT coeffients by taking the inverse DCT: `iDCT(F_ape_8x8_dQ)`.
"""

# ╔═╡ 1ac941a5-c363-4860-9514-223b178d0a95
md"The next cell visualizes the original patch next to your reconstruction."

# ╔═╡ b5007746-3b3e-4efe-9a1b-7fce33e508cc
[showimage(ape_8x8), showimage(ape_8x8_dQ_reconstructed)]

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

# ╔═╡ 44025981-0704-4f58-8835-0550800466e5
md"Finally, we also define the dummy functions `save_to_disk` and `load_from_disk` for demonstration purposes."

# ╔═╡ 30de9cea-db37-4b41-9630-b1ce79cabbdd
function save_to_disk(filename, x)
	return x
end

# ╔═╡ 74593d63-c53a-4eb1-9047-b0089a0a5c86
function load_from_disk(filename, x) #of course it is ridiculous that this function would have x as an argument
	return x
end

# ╔═╡ e463e0e1-43c5-4f12-a991-f8a2c5a2645a
md"""
### The full JPEG Compression algorithm
#### JPEG on an ``8\times 8`` block

Summary of the JPEG algorithm:
"""

# ╔═╡ 51e26944-9a23-4e7e-b564-42956d7dd9ae
blockdiag"""blockdiag {
"img" -> "img - 128" -> "fDCT" -> quantize
group {
          label = "(not in this course)";
          color = "#EEEEAA";

          // Set group shape to 'line group' (default is box)
          //shape = line;

          // Set line style (effects to 'line group' only)
          //style = dashed;
		"huffman decode" <- "load .jpg" <- "save as .jpg" <- "huffman encode"  
}

dequantize -> iDCT -> "img rec. + 128" -> "img rec." 

img [color = "greenyellow", shape = roundedbox];
"img rec." [color = "lightgreen", shape = roundedbox];

"save as .jpg" [shape = flowchart.database, color="lightgray"];
"load .jpg" [shape = flowchart.database, color="lightgray"];
"huffman encode" [color="lightgray"];
"huffman decode" [color="lightgray"];

quantize -> "huffman encode" [folded];
"dequantize" <- "huffman decode" [folded];

}
"""

# ╔═╡ f2b65e80-9453-4042-b6fd-86fc6e03c152

#`img -> img - 128 -> fDCT -> Quantize -> Huffmann -> save `

#`load -> de-Huffmann -> Dequantize -> iDCT -> img' + 128 -> img'`
md"""
Note that 128 is substracted. This is because images are stored using values ranging from 0 to 255 and subtracting 128 centers them around 0.

Let's apply this on the ``8\times 8`` `jpeg_test` image. This same patch is also used in the paper that describes the JPEG standard. 
	
Complete the following cells to execute the JPEG algorithm on this ``8\times 8`` patch stored in the variable `jpeg_test`. 
	
The correct (but rounded) outputs from the original paper are defined behind the scenes so that you can compare them with your solutions. 
	
For example, the first variable you have to compute is `jpeg_test_fdct`. To verify that you computed it correctly, you can compare it with solution `solution_jpeg_test_fdct` that was defined behind the scenes in this notebook. 

You can prefix any variable with `solution_` in the remainder of this subsection to get the correct answer.

"""

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
end;

# ╔═╡ 4abd4de6-4b49-4ef7-a1ff-8ba24d769d44
md"Our test image:"

# ╔═╡ 7ab5d4ef-bbcf-49fa-a7e8-861e26e5c046
jpeg_test

# ╔═╡ 3b2dcff4-3dec-4045-9da6-dbbd58259939
md"Now compute its fDCT, don't forget to center around zero."

# ╔═╡ 8146e32c-23ef-4b90-816d-6489428d7a99
jpeg_test_fdct = zeros(N,N) #replace the zeros

# ╔═╡ b348d000-4c4e-4de5-96d7-60da8c25421d
md"!!! hint
	`fDCT(jpeg_test .- 128)`
"

# ╔═╡ 01287455-52df-45e0-803a-e1b525d68a73
jpeg_test_q = zeros(N,N) #replace the zeros

# ╔═╡ 9bc6ff2a-19c0-4c2a-9329-44fecb721cfb
md"!!! hint
	`quantize(jpeg_test_fdct, Q_table)`
"

# ╔═╡ b72ef8a0-1816-4773-965b-c8cb7ad13562
md"The `huffman`, `save_to_disk`, `load_from_disk` and `dehuffman` functions are just there for show. You could implement them as a homework exercise, although there probably already exists a `Huffman.jl` package"

# ╔═╡ 341c7ae5-d3e6-4731-857b-dc507883f1a5
jpeg_test_huffman = huffman(jpeg_test_q);

# ╔═╡ 47054fde-66d6-46e5-a2bf-eb08822d8a4d
jpeg_test_save = save_to_disk("test.jpg", jpeg_test_huffman); #this is equal to jpeg_test_huffman

# ╔═╡ f0ca2719-7285-46a1-b391-1092fb46ddd5
jpeg_test_load = load_from_disk("test.jpg", jpeg_test_save); #this is still equal to jpeg_test_huffman. A real load function would of course never have the second argument

# ╔═╡ 1b8ecc6b-4648-497d-a10e-45536c38a140
jpeg_test_dehuffman = dehuffman(jpeg_test_load);

# ╔═╡ 51ac60e5-8978-4d71-bc72-dddddf95e050
md"Next, we can compute the dequantization of `jpeg_test_dehuffman`. Note that huffman encoding is lossless, so `jpeg_test_dehuffman` should be exactly equal to `jpeg_test_q`."

# ╔═╡ af556b44-3f25-44be-87b1-36060f40dbbc
jpeg_test_dq = zeros(N,N) #replace the zeros

# ╔═╡ bee5ad35-ba0c-4d5c-a1bc-efc6cf85d4c4
md"!!! hint
	`dequantize(jpeg_test_dehuffman, Q_table)`
"

# ╔═╡ adc580f9-d07a-4abf-b4ea-5fc1832dd03d
jpeg_test_rec = zeros(N,N) #replace the zeros

# ╔═╡ 67fcf0c6-06b5-41ca-93d0-fe66324b414d
md"!!! hint
	`iDCT(jpeg_test_dq) .+ 128`
"

# ╔═╡ 0cb4042f-8259-478e-bad2-b3a722039f45
md"Now you can round `jpeg_test_rec` and compare it to `solution_jpeg_test_rec`. You can use `floor(Int, x + 0.5)` to round a scalar `x` to the nearest integer. Don't forget to vectorize it."

# ╔═╡ eb9d184c-d486-4f20-93f3-b9842c88eb3d
#compare solution_jpeg_test_rec to a rounded copy of jpeg_test_rec

# ╔═╡ 85529a43-92ef-4d1f-b1e7-f60d8faa13ea
md"!!! hint
	`solution_jpeg_test_rec - floor.(Int, 0.5 .+ jpeg_test_rec)`
"

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
md"#### The full JPEG algorithm on the full 512x512 ape image

First, pick a quantization table. By default we will just copy `Q_table` from before. You are encouraged to come up with your own quantization tables or to look for some on the internet. 

Setting `Q = ones(N,N)` leads to minimal compression, caused by rounding from the `floor` function."

# ╔═╡ 63f2e841-13a2-4bb9-bd4d-904fa9d51011
Q = copy(Q_table) #define this Q yourself, overwrite with any 8x8 table

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

# ╔═╡ 274a8748-4c90-4e9c-bbf9-f9635695f540
md"Note how the quantized version of the image, i.e. `ape_q`, consists of ``8\times 8`` patches of quantized coefficients."

# ╔═╡ fc1ef559-a7bc-4aed-90ff-8b500bcbc44e
ape_huff = apply_on_sub(huffman, ape_q); # == ape_q

# ╔═╡ 046dd696-47f1-448b-8ac9-6a0baa0f0890
#save to disk
ape_save = save_to_disk("ape.jpg", ape_huff); #dummy function for demonstration purposes

# ╔═╡ 62db95a7-72f3-40de-bff6-48a8b33a24ec
#load from disk
ape_load = load_from_disk("ape.jpg", ape_save) #dummy function for demonstration purposes

# ╔═╡ 39187e75-2ade-4296-8a27-cdd2d4e097c5
ape_dehuff = apply_on_sub(dehuffman, ape_load); #ape_load == ape_q still

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

# ╔═╡ e278d23a-0394-48c9-aa0d-944a1a4a76c6
md"This heatmap shows the difference between the original image and its JPEG compressed version."

# ╔═╡ de747f85-0a94-4d0b-907b-021e36acd431
heatmap(reverse(ape - ape_reconstructed, dims=1))

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Kroki = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
TestImages = "5e47fb64-e119-507b-a336-dd2b206d9990"

[compat]
Images = "~0.25.0"
Kroki = "~0.1.0"
Plots = "~1.25.3"
PlutoUI = "~0.7.27"
TestImages = "~1.6.2"
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
git-tree-sha1 = "9faf218ea18c51fcccaf956c8d39614c9d30fe8b"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.2"

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
git-tree-sha1 = "d711603452231bad418bd5e0c91f1abd650cba71"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.3"

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

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

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

[[Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78e2c69783c9753a91cdae88a8d432be85a2ab5e"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+0"

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
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

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
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f025b79883f361fa1bd80ad132773161d231fd9f"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+2"

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
git-tree-sha1 = "09ef0c32a26f80b465d808a1ba1e85775a282c97"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.17"

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

[[Kroki]]
deps = ["Base64", "CodecZlib", "DocStringExtensions", "HTTP"]
git-tree-sha1 = "1f0c3d257c94012f79d0381914460b2339fe1be9"
uuid = "b3565e16-c1f2-4fe9-b4ab-221c88942068"
version = "0.1.0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

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
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
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
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

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
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

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
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

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
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

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
deps = ["SHA", "Serialization"]
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
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StringDistances]]
deps = ["Distances", "StatsAPI"]
git-tree-sha1 = "ceeef74797d961aee825aabf71446d6aba898acb"
uuid = "88034a9c-02f8-509d-84a9-84ec65e18404"
version = "0.11.2"

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

[[TestImages]]
deps = ["AxisArrays", "ColorTypes", "FileIO", "OffsetArrays", "Pkg", "StringDistances"]
git-tree-sha1 = "f91d170645a8ba6fbaa3ac2879eca5da3d92a31a"
uuid = "5e47fb64-e119-507b-a336-dd2b206d9990"
version = "1.6.2"

[[TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "c342ae2abf4902d65a0b0bf59b28506a6e17078a"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.2"

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

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

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
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

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
# ╟─928488a0-0af4-11ec-34a7-23dcf9e45875
# ╟─70cdd2c1-9f7b-4421-8ad4-8e5c5ca56e42
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
# ╠═65dd7c05-4338-480d-8b8d-9a60af44b1ff
# ╟─8ba903f4-ce62-422c-83db-6076a6c6b932
# ╠═297bba22-b28a-4f82-baf9-c472a985f737
# ╟─cd31de7a-75ef-4722-b180-e78b58448231
# ╠═8f967b5a-f29e-444d-8df4-3c7660d4f591
# ╟─5b6e5cd8-8bab-4687-a7e2-6a348a3634b7
# ╟─5567f616-76fb-4224-bb9d-df92738637a6
# ╟─7f07e91d-c7c9-46d9-8631-128b3cd6cd16
# ╟─eec317e1-94f0-4e3a-8cdf-341b8f47a712
# ╟─dd8ad5ea-2bae-4e4d-9688-13c8c7cc99ef
# ╟─a79c0b69-8947-4e59-9f9e-47c0feef7512
# ╟─fc78b1b5-344a-48c1-b772-6ff2bf36102d
# ╠═ff6562fb-e4a6-48ef-9f28-bab52f6b9d1b
# ╠═66d17414-fb64-41d8-9271-311bf70d727b
# ╟─8a8fb63f-2893-4110-af62-ed56ccb7693f
# ╟─28032d35-b1a2-4cc0-8f6c-6a8b8af45666
# ╠═639da4db-37c8-4705-9331-f359b0d43570
# ╟─ffb97560-da59-4518-a2b3-2c1c499e8ca9
# ╠═082a2eab-5c8d-4d67-af92-d0733a4fbda1
# ╟─fce789f4-724b-4f48-81a4-bd77b9005e60
# ╟─6447cae8-2f83-42c9-97e1-dc3c1a506624
# ╠═ad9ceaa9-83a8-4910-968f-17e69ecc7b31
# ╟─d7815fde-1073-461e-baad-3110937f5c9e
# ╠═70c04d56-c7c7-45f0-8148-a5b6f228880e
# ╟─f27c2860-8798-4715-b6e7-dc8414fa65e3
# ╟─382b9046-d722-43d7-9708-355c0d76b7ae
# ╠═3d49ae24-11b2-46e1-bfcc-96cf4f85cc25
# ╠═bc6a83f7-e2ea-4d32-9f02-af61cb24b727
# ╟─121b9243-67d4-49d7-83bb-51e0743635f6
# ╠═4896169d-1329-4af4-81c5-134e19cb8f25
# ╟─35966491-1b10-4420-b0ad-218f871911c5
# ╟─1ae10f9f-d10e-4a4f-b0fd-65255a1c222d
# ╠═fdcef284-cf62-4108-8ccb-ecf29d176aaa
# ╟─2d382a94-560e-4aa7-86bb-53f0d7d34859
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
# ╟─29d0df00-c037-4dfa-be6a-ac1bacb24dfb
# ╠═bf5f1e1b-0d1a-45bd-9860-eb693cbdcb37
# ╟─7867fe0f-98d6-48e8-843d-3524c48c4507
# ╟─2007667c-0d89-4016-a251-daaa4503b35f
# ╟─09fddae7-3def-4ba4-bce7-bb6aacc47394
# ╠═06f12618-ae69-4df7-8437-b21970454f47
# ╟─b50b9add-0ab2-475c-88ac-46650aa48e8d
# ╟─bdb9d1f0-fdf0-443d-945f-4ce99ef63ecc
# ╠═c288bd95-9f38-4051-a552-2535ba745c92
# ╟─039ff778-b4a2-40db-9a00-737b606ffa9f
# ╠═fee8015c-a1ff-4e88-8ccb-601771c71b7a
# ╠═61328db4-9dfb-453b-8644-58885d9f3cf1
# ╟─21eea844-6779-4c23-8248-325bc46a1499
# ╠═af4dbb1a-d969-4d5a-b847-969ad72cb081
# ╟─3f9acd0e-8910-4d60-a5fe-14598063de11
# ╟─2f809fae-6b70-40b1-b208-16c5a0393621
# ╠═e21b9f59-515a-4c62-8886-439a55c05836
# ╟─0fdb8d99-6858-485e-b80a-42ff65288988
# ╟─57089d2d-bae5-49f0-84cc-ec0bbb61e7e9
# ╠═b5c5abb0-4ece-460d-8bd6-347bc11a4d4a
# ╟─ab508749-3643-4bfb-8409-0b23d4225472
# ╠═e7fb3c5a-bfcc-4656-a277-b311a5b02ad7
# ╟─a0bd7604-c8a0-4373-b286-faf004de6c17
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
# ╟─7e609a2d-8903-4717-b180-d64994fb3eb0
# ╠═c5f20a8f-b145-45cc-b025-4460cfa8be96
# ╟─9fdb6840-1e98-4905-91ed-db666dd5f09f
# ╟─2870c406-21e2-4307-a0e4-33213c79a511
# ╠═bb1edccd-db05-4b21-8079-a73765717937
# ╟─604816cb-dc08-48c3-bfe8-cd88c159999d
# ╟─cbde8c90-e06c-4605-9fcc-e07b737f10a1
# ╟─384f7275-00ee-4aec-8880-fe8e04a86a0b
# ╠═355165c7-f3f3-4f7c-a776-0f5498c0f0fc
# ╟─b90dc81c-77d4-4e11-be7f-66bc39f3539e
# ╟─69222397-6c1a-4bd6-a883-d36584deccc6
# ╠═3892a59d-4e82-47eb-8ef1-3befd46e7ba0
# ╟─26c65705-46d4-4ca3-b0de-1f1fb6ce9054
# ╠═fadb1828-fcb3-4207-92fe-c88a75964644
# ╟─a50bf599-dcc2-4560-b276-50caa116adfc
# ╟─1ac941a5-c363-4860-9514-223b178d0a95
# ╠═b5007746-3b3e-4efe-9a1b-7fce33e508cc
# ╟─8385b715-6a9d-4938-9886-09f9d0e81bf3
# ╠═d2eb6604-5f64-492b-ad86-6446613b091e
# ╠═8ff477eb-938f-48c2-84c1-519f741ec142
# ╟─44025981-0704-4f58-8835-0550800466e5
# ╠═30de9cea-db37-4b41-9630-b1ce79cabbdd
# ╠═74593d63-c53a-4eb1-9047-b0089a0a5c86
# ╟─e463e0e1-43c5-4f12-a991-f8a2c5a2645a
# ╟─51e26944-9a23-4e7e-b564-42956d7dd9ae
# ╟─f2b65e80-9453-4042-b6fd-86fc6e03c152
# ╟─bb18bcd3-5251-4b17-8e5b-f96c0d667aec
# ╟─4abd4de6-4b49-4ef7-a1ff-8ba24d769d44
# ╠═7ab5d4ef-bbcf-49fa-a7e8-861e26e5c046
# ╟─3b2dcff4-3dec-4045-9da6-dbbd58259939
# ╠═8146e32c-23ef-4b90-816d-6489428d7a99
# ╟─b348d000-4c4e-4de5-96d7-60da8c25421d
# ╠═01287455-52df-45e0-803a-e1b525d68a73
# ╟─9bc6ff2a-19c0-4c2a-9329-44fecb721cfb
# ╟─b72ef8a0-1816-4773-965b-c8cb7ad13562
# ╠═341c7ae5-d3e6-4731-857b-dc507883f1a5
# ╠═47054fde-66d6-46e5-a2bf-eb08822d8a4d
# ╠═f0ca2719-7285-46a1-b391-1092fb46ddd5
# ╠═1b8ecc6b-4648-497d-a10e-45536c38a140
# ╟─51ac60e5-8978-4d71-bc72-dddddf95e050
# ╠═af556b44-3f25-44be-87b1-36060f40dbbc
# ╟─bee5ad35-ba0c-4d5c-a1bc-efc6cf85d4c4
# ╠═adc580f9-d07a-4abf-b4ea-5fc1832dd03d
# ╟─67fcf0c6-06b5-41ca-93d0-fe66324b414d
# ╟─0cb4042f-8259-478e-bad2-b3a722039f45
# ╠═eb9d184c-d486-4f20-93f3-b9842c88eb3d
# ╟─85529a43-92ef-4d1f-b1e7-f60d8faa13ea
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
# ╟─274a8748-4c90-4e9c-bbf9-f9635695f540
# ╠═fc1ef559-a7bc-4aed-90ff-8b500bcbc44e
# ╠═046dd696-47f1-448b-8ac9-6a0baa0f0890
# ╠═62db95a7-72f3-40de-bff6-48a8b33a24ec
# ╠═39187e75-2ade-4296-8a27-cdd2d4e097c5
# ╠═dfb4f706-3fe2-43bd-9e01-3fba3b0898f9
# ╠═a4cbdb28-ae80-41e7-adbf-8dd58edf9a1e
# ╠═17797b73-fe82-4722-b6ab-0ca7b340ba69
# ╠═6129b8cb-633d-4179-bf72-3bb7c31706a1
# ╟─15e35d70-56ab-4e02-ac71-2fa78e417982
# ╟─e278d23a-0394-48c9-aa0d-944a1a4a76c6
# ╠═de747f85-0a94-4d0b-907b-021e36acd431
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
