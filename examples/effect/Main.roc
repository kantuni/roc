app "effect-example"
    packages { base: "thing/platform-dir" }
    imports [ base.Task.{ Task, after } ]
    provides [ main ] to base

main : Task.Task {} F64
main =
    Task.after (Task.putLine "foo") \{} ->
        Task.putLine "bar"

