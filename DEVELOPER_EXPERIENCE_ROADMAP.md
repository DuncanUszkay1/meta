# Developer Experience Roadmap

The "Developer Experience" Roadmap will highlight popular, and notable projects in the AssemblyScript ecosystem that help to improve Developer Experience. This will include projects that are tools, libraries, documentation, etc... . This is not a complete list, as many tools and libraries exist for AssemblyScript, but this will mostly highlight tools created by the AssemblyScript team, or notable communitty members. Please feel free to open issues for any comments, questions, or concerns with the current roadmap.

Another thing to note, since AssemblyScript is very similar to [TypeScript](https://www.typescriptlang.org/), a lot of TypeScript and JavaScript ecosystem and support works "out-of-the-box", sometimes with very minimal tweaking to work, with AssemblyScript. For example, [npm](https://www.npmjs.com/) for package management, the TypeScript compiler, TypeScript language servers for syntax highlting and things, etc... . Also, AssemblyScript is built on top of [Binaryen](https://github.com/WebAssembly/binaryen), which means a lot of general WebAssembly Ecosystem improvements will generally work with AssemblyScript modules.

# Table of Contents

* [Developer Experience Roadmap](#developer-experience-roadmap)
* [Table of Contents](#table-of-contents)
* [Testing](#testing)
  * [as-pect](#as-pect)
* [High Level Data Binding](#high-level-data-binding)
  * [as-bind](#as-bind)
* [WASI](#wasi)
  * [AssemblyScript/node](#assemblyscriptnode)
* [Utility](#utility)
* [Documentation](#documentation)
  * [AssemblyScript Documentation](#assemblyscript-documentation)
  * [WasmByExample](#wasmbyexample)

# Testing

## as-pect

[Repo](https://github.com/jtenner/as-pect)

*Last Updated: March 4th, 2019*

TODO

# High Level Data Binding

## as-bind

[Repo](https://github.com/torch2424/as-bind).

*Last Updated: March 4th, 2019*

Currently supports string and typed arrays, as stated in it's [compatibility table](https://github.com/torch2424/as-bind#supported-data-types). The next goals include passing [closures](https://github.com/torch2424/as-bind/issues/17), and [user defined classes / objects](https://github.com/torch2424/as-bind/issues/20). 

# WASI

## AssemblyScript/node

[Repo](https://github.com/AssemblyScript/node).

*Last Updated: March 4th, 2019*

This project is meant to provide a "Node-like" experience for interacting with WASI by using AssemblyScript.

The current goal here is to get feature parity with another useful WASI libaray for AssemblyScript, [as-wasi](https://github.com/jedisct1/as-wasi). In the current state of WASI, building a useful `fs` module is probably the only thing that can currently be done. But this enables a lot of features in itself.

# Utility

*Last Updated: March 4th, 2019*

As highlighted by the [Febuary 12th, 2020 Communitty Meeting](https://github.com/AssemblyScript/meta/issues/21#issuecomment-585394670), some feedback we recieved from Wasm Summit was to offer some Utility libraries.

A good place to start on this effort is looking at some of the libraries highlighted in [this article](https://blog.bitsrc.io/11-javascript-utility-libraries-you-should-know-in-2018-3646fb31ade). Another good resource would be to look through some the [most depended upon npm packages](https://www.npmjs.com/browse/depended), and writing a port of them to AssemblyScript.

# Documentation

## AssemblyScript Documentation

[Repo](https://github.com/AssemblyScript/docs) [Website](https://docs.assemblyscript.org/)

*Last Updated: March 4th, 2019*

The AssemblyScript documentation is meant to provide small exaples, to nitty-gritty details about the syntax and runtime behavior of the language. It's current goal is to just kepe up with the changes from the [AssemblyScript compiler](https://github.com/AssemblyScript/assemblyscript).

## WasmByExample

[Repo](https://github.com/torch2424/wasm-by-example) [Website](https://wasmbyexample.dev/)

*Last Updated: March 4th, 2019*

Wasm By Example is a concise, hands-on introduction to WebAssembly using code snippets and annotated WebAssembly example programs. 

It's goal concerning the project is meant to provide a quick and easy way for AssemblyScript developers to reference code snippets they can copy and past into their projects. As well as, understanding on how to apply AssemblyScript in different contexts.

It's current roadmap is to fix [Language inconsistencies](https://github.com/torch2424/wasm-by-example/issues/34), highlight [additional data binding techniques](https://github.com/torch2424/wasm-by-example/issues/68), highlight [AssemblyScript Runtime Specifics](https://github.com/torch2424/wasm-by-example/issues/56), create examples for [more toolchains](https://github.com/torch2424/wasm-by-example/issues/3), and create examples for [platforms outside of the browser](https://github.com/torch2424/wasm-by-example/issues/2).

