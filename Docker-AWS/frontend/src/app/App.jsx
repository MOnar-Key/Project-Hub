import "./App.css"
import { Editor } from "@monaco-editor/react"
import { MonacoBinding } from "y-monaco"
import { useRef, useMemo, useState } from "react"
import * as Y from "yjs"
import { SocketIOProvider } from "y-socket.io"

function App() {
  const EditorRef = useRef(null)
  const [username, setUsername] = useState(() => {
    return new URLSearchParams(window.location.search).get("username") || ""
  })
  const [ users, setUsers ] = useState([])
  const ydoc = useMemo(() => new Y.Doc(), [])
  const yText = useMemo(() => ydoc.getText("monaco"), [ydoc])

  // ✅ Everything inside handleMount — no useEffect needed
  const handleMount = (Editor) => {
    EditorRef.current = Editor

    if (!username) return  // ✅ Guard — if no username, don't connect

    const provider = new SocketIOProvider(
      "/",
      "monaco",
        ydoc,
      { autoConnect: true }
    )
    provider.awareness.setLocalStateField("user", { username })
    provider.awareness.on("change", () => {
      const states = Array.from(provider.awareness.getStates().values())
      setUsers(states.filter(state => state.user && state.user.username).map(state => state.user))
    })
    function handleBeforeUnload(){
      provider.awareness.setLocalStateField("user", null)
    } 
    window.addEventListener("beforeunload", handleBeforeUnload)

    const monacoBinding = new MonacoBinding(
      yText,
      EditorRef.current.getModel(),
      new Set([EditorRef.current]),
      provider.awareness
    )
    return () => {
      monacoBinding.destroy()
      provider.disconnect()
      window.removeEventListener("beforeunload", handleBeforeUnload)
    }
  }

  const handleJoin = (e) => {
    e.preventDefault()
    const name = e.target.username.value
    setUsername(name)
    window.history.pushState({}, "", "?username=" + name)
  }

  // ✅ Show login form if no username
  if (!username) {
    return (
      <main className="h-screen w-full bg-gray-950 flex items-center justify-center">
        <form
          onSubmit={handleJoin}
          className="flex flex-col gap-4"
        >
          <input
            type="text"
            placeholder="Enter your username"
            className="p-2 rounded-lg bg-gray-800 text-white"
            name="username"
          />
          <button
            className="p-2 rounded-lg bg-amber-50 text-gray-950 font-bold" // ✅ font-bold fixed
          >
            Join
          </button>
        </form>
      </main>
    )
  }

  // ✅ Show editor after username is set
  return (
    <main className="h-screen w-full bg-gray-950 flex gap-4 p-4">
      <aside className="h-full w-1/4 bg-amber-50 rounded-lg">
      <h2 className="text-2xl font-bold p-4 border-b border-gray-300">Users</h2>
      <ul className="p-4">
        {users.map((user,index)=> (
          <li key={index} className="p-2 bg-gray-800 text-white rounded mb-2">
            {user.username}
          </li>
        ))}
      </ul>
        </aside>
      <section className="w-3/4 bg-neutral-800 rounded-lg overflow-hidden">
        <Editor
          height="100%"
          defaultLanguage="javascript"
          defaultValue="// some comment"
          theme="vs-dark"
          onMount={handleMount}
        />
      </section>
    </main>
  )
}

export default App