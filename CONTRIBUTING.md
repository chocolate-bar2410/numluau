# Contributing to the project

Thanks for contributing.
Since this is a foundational math library, code is held to higher standards of safety, consistency and performance.
Scientists and engineers expect this library to be precise and numerically stable.

## requirements
Before you start contributing, ensure you have the following tools installed.

- **luau ecosystem**
    - [rokit](https://github.com/rojo-rbx/rokit)
    - [lune](https://lune-org.github.io/docs/) (or similar runtime)
- **python ecosystem**
    - python 3.x
    - pip
    - [zensical](https://zensical.org/)
    - [numpy](https://numpy.org/) (Optional but good for benchmarking and comparisions).

### setting up the documentation environment
When using zensical it is [recommended](https://zensical.org/docs/get-started/) to run it in a virtual environment.
```bash
# Creating and activating the virtual environment.
python -m venv .venv  
.venv\Scripts\activate

# Installing the required documentation tools.
pip install zensical
```

To preview and run the documentation locally run:
```
zensical serve
```

## code guide
- **Indents:** Code indents must use tabs for indentation, not spaces. 
    - *exception for aligning code to be more readable*

- **Runtime agnostic:** Code is expected to be entirely runtime agnostic so that it remains available to every developer.
    - avoid using runtime specific features such as FFI or file reading within the core library.

## AI usage policy
As this is a math/science library, AI usage is restricted to protect the safety, reliability and correctness of the codebase.
Generative AI lacks intent, cannot gaurantee numerical stability and is highly prone to hallucinations.

If you use generative AI, you must:
- **Disclose** where Generative AI was used in your contribution
- **Justify** why Generative AI was necessary or beneficial.
- **Explain** thoroughly how the resulting code works. If you cannot explain, dont submit it.

### Allowed *(subject to the rules from above)*:
- **Documentation:** drafting or improving english documentation.
- **Unit test data & scenarios:** Generating mock data, boundary values or inputs for testing.

### Prohibited:
- **Core functionality:** Any library computation, core algorithm or math logic.
- **Utility/Helper methods:** Even simple helper functions should be human written to ensure optimal performance.
- **Objects:** Implementation of objects like ndArrays, polynomials, generators or some other data structure.
- **Unit test infrastructure:** Core framework logic of how the unit test system operates.
- **Automated translation:** Translating the documentation into other human languages (Mandarin, Japanese, Korean etc.). Technical Translations require human precision to avoid misunderstandings of mathematical concepts. 

Machine translations are banned as to ensure localisations remain natural, and precise for non english speakers.
