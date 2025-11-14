(module magic.plugin.lspconfig
  {autoload {util magic.util
             nvim aniseed.nvim}})

(defn exepath [exe]
  "Return the full path of the given executable if it exists, otherwise nil."
  (if (vim.fn.executable exe)
    (vim.fn.exepath exe)
    nil))

(defn- map [from to]
  (util.nnoremap from to))

(defn- setup-fennel [lsp]
  (let [pwd (vim.loop.cwd)]
    (pcall
      #(with-open [cfg (io.open (.. pwd "/" ".fennel-ls.json"))]
        (let [fennel-ls
              (-> (cfg:read "*a")
                  vim.json.decode)]
          (lsp.fennel_ls.setup {:settings {: fennel-ls}}))))))
(fn get-tsserver-path []
  (let [(ok? ret)
        (pcall #(with-open [f (io.popen
                                "which node")]
                  (f:read "*a")))]
    (if ok?
      (let [(r _)
            (string.gsub ret "bin/node%s$" "lib/node_modules/typescript/lib/tsserver.js")]
        r)
      nil)))


(fn get-capabilities []
  (let [(ok? cmp) (pcall #(require :cmp_nvim_lsp))]
    (if ok
      (cmp.default_capabilities)
      (vim.lsp.protocol.make_client_capabilities))))

(fn is-deno []
  (let [(stat err) (vim.loop.fs_stat
                     (.. (vim.fn.getcwd)
                         "/"
                         :deno.jsonc))]
    (if (not= nil stat)
      true
      (let [(stat err) (vim.loop.fs_stat
                         (.. (vim.fn.getcwd)
                             "/"
                             :deno.json))]
        (not= nil stat)))))

(vim.api.nvim_create_user_command 
  :LspDeno
  (fn []
    (let [lsp (require :lspconfig)]
      (vim.api.nvim_command "LspStop 0 (vtsls)")
      (vim.api.nvim_command "LspStart denols")))
  {})

(let [
      capabilities (get-capabilities)
      neodev (require :neodev)]
      ;(_ util) (pcall #(require :lspconfig/util))]
  (neodev.setup {})
  ;; nvim-ufo
  (tset capabilities.textDocument :foldingRange
        {:dynamicRegistration false
         :lineFoldingOnly true})
  (tset capabilities :textDocument :completion :completionItem :snippetSupport
        true)
  (vim.lsp.enable :ts_ls)
  (vim.lsp.enable :jsonls)
  (vim.api.nvim_create_user_command
    :LspSetup
    #(util.pick 
       [
        :ada_ls
        :agda_ls
        :aiken
        :air
        :alloy_ls
        :anakin_language_server
        :angularls
        :ansiblels
        :antlersls
        :apex_ls
        :arduino_language_server
        :asm_lsp
        :ast_grep
        :astro
        :atlas
        :autohotkey_lsp
        :autotools_ls
        :awk_ls
        :azure_pipelines_ls
        :bacon_ls
        :ballerina
        :basedpyright
        :bashls
        :basics_ls
        :bazelrc_lsp
        :beancount
        :bicep
        :biome
        :bitbake_language_server
        :bitbake_ls
        :blueprint_ls
        :bqnlsp
        :bright_script
        :bsl_ls
        :buck2
        :buddy_ls
        :buf_ls
        :bufls
        :bzl
        :c3_lsp
        :cadence
        :cairo_ls
        :ccls
        :cds_lsp
        :circom-lsp
        :clangd
        :clarity_lsp
        :clojure_lsp
        :cmake
        :cobol_ls
        :codeqlls
        :coffeesense
        :contextive
        :coq_lsp
        :crystalline
        :csharp_ls
        :cssls
        :cssmodules_ls
        :css_variables
        :cucumber_language_server
        :cue
        :custom_elements_ls
        :cypher_ls
        :daedalus_ls
        :dafny
        :dagger
        :dartls
        :dcmls
        :debputy
        :delphi_ls
        :denols
        :dhall_lsp_server
        :diagnosticls
        :digestif
        :djlsp
        :docker_compose_language_service
        :dockerls
        :dolmenls
        :dotls
        :dprint
        :drools_lsp
        :ds_pinyin_lsp
        :dts_lsp
        :earthlyls
        :ecsact
        :efm
        :elixirls
        :elmls
        :elp
        :ember
        :emmet_language_server
        :emmet_ls
        :erg_language_server
        :erlangls
        :esbonio
        :eslint
        :facility_language_server
        :fennel_language_server
        :fennel_ls
        :fish_lsp
        :flow
        :flux_lsp
        :foam_ls
        :fortls
        :fsautocomplete
        :fsharp_language_server
        :fstar
        :futhark_lsp
        :gdscript
        :gdshader_lsp
        :gh_actions_ls
        :ghcide
        :ghdl_ls
        :ginko_ls
        :gitlab_ci_ls
        :glasgow
        :gleam
        :glint
        :glsl_analyzer
        :glslls
        :golangci_lint_ls
        :gopls
        :gradle_ls
        :grammarly
        :graphql
        :groovyls
        :guile_ls
        :harper_ls
        :haxe_language_server
        :hdl_checker
        :helm_ls
        :hhvm
        :hie
        :hlasm
        :hls
        :hoon_ls
        :html
        :htmx
        :hydra_lsp
        :hyprls
        :idris2_lsp
        :intelephense
        :janet_lsp
        :java_language_server
        :jdtls
        :jedi_language_server
        :jinja_lsp
        :jqls
        :jsonls
        :jsonnet_ls
        :julials
        :kcl
        :koka
        :kotlin_language_server
        :kulala_ls
        :lean3ls
        :leanls
        :lelwel_ls
        :lemminx
        :lexical
        :lsp_ai
        :ltex
        :ltex_plus
        :lua_ls
        :luau_lsp
        :lwc_ls
        :m68k
        :markdown_oxide
        :marko-js
        :marksman
        :matlab_ls
        :mdx_analyzer
        :mesonlsp
        :metals
        :millet
        :mint
        :mlir_lsp_server
        :mlir_pdll_lsp_server
        :mm0_ls
        :mojo
        :motoko_lsp
        :move_analyzer
        :msbuild_project_tools_server
        :mutt_ls
        :nelua_lsp
        :neocmake
        :nextflow_ls
        :nextls
        :nginx_language_server
        :nickel_ls
        :nil_ls
        :nim_langserver
        :nimls
        :nixd
        :nomad_lsp
        :ntt
        :nushell
        :nxls
        :ocamlls
        :ocamllsp
        :ols
        :omnisharp
        :opencl_ls
        :openedge_ls
        :openscad_ls
        :openscad_lsp
        :oxlint
        :pact_ls
        :pasls
        :pbls
        :perlls
        :perlnavigator
        :perlpls
        :pest_ls
        :phan
        :phpactor
        :pico8_ls
        :pkgbuild_language_server
        :please
        :poryscript_pls
        :postgres_lsp
        :powershell_es
        :prismals
        :prolog_ls
        :prosemd_lsp
        :protols
        :psalm
        :pug
        :puppet
        :purescriptls
        :pylsp
        :pylyzer
        :pyre
        :pyright
        :qmlls
        :qml_lsp
        :quick_lint_js
        :racket_langserver
        :raku_navigator
        :reason_ls
        :regal
        :regols
        :relay_lsp
        :remark_ls
        :rescriptls
        :r_language_server
        :rls
        :rnix
        :robotcode
        :robotframework_ls
        :roc_ls
        :rome
        :rubocop
        :ruby_lsp
        :ruff_lsp
        :ruff
        :rune_languageserver
        :rust_analyzer
        :salt_ls
        :scheme_langserver
        :scry
        :selene3p_ls
        :serve_d
        :shopify_theme_ls
        :sixtyfps
        :slangd
        :slint_lsp
        :smarty_ls
        :smithy_ls
        :snakeskin_ls
        :snyk_ls
        :solang
        :solargraph
        :solc
        :solidity_ls
        :solidity_ls_nomicfoundation
        :solidity
        :somesass_ls
        :sorbet
        :sourcekit
        :sourcery
        :spectral
        :spyglassmc_language_server
        :sqlls
        :sqls
        :standardrb
        :starlark_rust
        :starpls
        :statix
        :steep
        :stimulus_ls
        :stylelint_lsp
        :stylua3p_ls
        :superhtml
        :svelte
        :svlangserver
        :svls
        :swift_mesonls
        :syntax_tree
        :systemd_ls
        :tabby_ml
        :tailwindcss
        :taplo
        :tblgen_lsp_server
        :teal_ls
        :templ
        :terraformls
        :terraform_lsp
        :texlab
        :textlsp
        :tflint
        :theme_check
        :thriftls
        :tilt_ls
        :tinymist
        :ts_ls
        :tsp_server
        :ts_query_ls
        :ttags
        :turbo_ls
        :turtle_ls
        :tvm_ffi_navigator
        :twiggy_language_server
        :typeprof
        :typos_lsp
        :typst_lsp
        :uiua
        :ungrammar_languageserver
        :unison
        :unocss
        :uvls
        :vacuum
        :vala_ls
        :vale_ls
        :v_analyzer
        :vdmj
        :verible
        :veridian
        :veryl_ls
        :vhdl_ls
        :vimls
        :visualforce_ls
        :vls
        :volar
        :vscoqtop
        :vtsls
        :vuels
        :wasm_language_tools
        :wgsl_analyzer
        :yamlls
        :yang_lsp
        :yls
        :ziggy
        :ziggy_schema
        :zk
        :zls]
       "Select Language Server"
       #(do 
          (vim.lsp.config $1  {: capabilities})
          (vim.lsp.enable $1)))
    {:desc "Switch Model"}))

       ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
