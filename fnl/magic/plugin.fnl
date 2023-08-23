(module magic.plugin
  {autoload {a aniseed.core
             lazy lazy}})

(defn- safe-require-plugin-config [name]
  "Safely require a module under the magic.plugin.* prefix. Will catch errors
  and print them while continuing execution, allowing other plugins to load
  even if one configuration module is broken."
  (if name
    (let [(ok? val-or-err) (pcall require (.. "magic.plugin." name))]
      (when (not ok?)
        (print (string.format "Plugin (%s) config error: (%s)" name val-or-err))))))

(defn req [name]
  "A shortcut to building a require string for your plugin
  configuration. Intended for use with packer's config or setup
  configuration options. Will prefix the name with `magic.plugin.`
  before requiring."
  (.. "require('magic.plugin." name "')"))

(defn use [...]
  "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well.

  This is just a helper / syntax sugar function to make interacting with packer
  a little more concise."
  (let [pkgs [...]]
    (let [plugins []]
      (for [i 1 (a.count pkgs) 2]
           (let [name (. pkgs i)
                 opts (. pkgs (+ i 1))]
             (tset opts :dependencies
                   (or opts.dependencies
                       opts.requires))
             (tset opts :run
                   (or opts.run
                       opts.build))

             (tset opts 1 name)
             (if (. opts :mod)
               (tset opts :config
                     (fn []
                      (-?> (. opts :mod) (safe-require-plugin-config)))))
             (table.insert plugins opts)))
      (lazy.setup
        plugins
        {:dev {:path "/home/yj/github"}}))))
