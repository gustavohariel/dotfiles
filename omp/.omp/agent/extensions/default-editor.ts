// OMP runs under herdr, which does not source fish config before spawning agents.
// Set the editor inside OMP so external-editor shortcuts work in every pane.
export default function () {
  process.env.EDITOR ??= "nvim";
  process.env.VISUAL ??= "nvim";
}
