document.addEventListener("click", function (b) {
  try {
    var p = function (a) {
      return (v && a.getAttribute("data-sort-alt")) || a.getAttribute("data-sort") || a.innerText;
    },
      q = function (a, c) {
        a.className = a.className.replace(w, "") + c;
      },
      g = function (a, c) {
        return a.nodeName === c ? a : g(a.parentNode, c);
      },
      w = / dir-(u|d) /,
      v = b.shiftKey || b.altKey,
      e = g(b.target, "TH"),
      r = g(e, "TR"),
      f = g(r, "TABLE");
    if (/\bsortable\b/.test(f.className)) {
      var l,
        d = r.cells;
      for (b = 0; b < d.length; b++) d[b] === e ? (l = e.getAttribute("data-sort-col") || b) : q(d[b], "");
      d = " dir-d ";
      if (-1 !== e.className.indexOf(" dir-d ") || (-1 !== f.className.indexOf("asc") && -1 == e.className.indexOf(" dir-u "))) d = " dir-u ";
      q(e, d);
      for (b = 0; b < f.tBodies.length; b++) {
        var m = f.tBodies[b],
          n = [].slice.call(m.rows, 0),
          t = " dir-u " === d;
        n.sort(function (a, c) {
          var h = p((t ? a : c).cells[l]),
            k = p((t ? c : a).cells[l]);
          return h.length && k.length && !isNaN(h - k) ? h - k : h.localeCompare(k);
        });
        for (var u = m.cloneNode(); n.length;) u.appendChild(n.splice(0, 1)[0]);
        f.replaceChild(u, m);
      }
    }
  } catch (a) { }
});
