(() => {
  var __create = Object.create;
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __getProtoOf = Object.getPrototypeOf;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __commonJS = (cb, mod) => function __require() {
    return mod || (0, cb[__getOwnPropNames(cb)[0]])((mod = { exports: {} }).exports, mod), mod.exports;
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
    // If the importer is in node compatibility mode or this is not an ESM
    // file that has been converted to a CommonJS file using a Babel-
    // compatible transform (i.e. "__esModule" has not been set), then set
    // "default" to the CommonJS "module.exports" for node compatibility.
    isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
    mod
  ));

  // js/vendor/cropper.js
  var require_cropper = __commonJS({
    "js/vendor/cropper.js"(exports, module) {
      !function(t, e) {
        "object" == typeof exports && "undefined" != typeof module ? module.exports = e() : "function" == typeof define && define.amd ? define(e) : (t = "undefined" != typeof globalThis ? globalThis : t || self).Cropper = e();
      }(exports, function() {
        "use strict";
        function C(e2, t2) {
          var i2, a2 = Object.keys(e2);
          return Object.getOwnPropertySymbols && (i2 = Object.getOwnPropertySymbols(e2), t2 && (i2 = i2.filter(function(t3) {
            return Object.getOwnPropertyDescriptor(e2, t3).enumerable;
          })), a2.push.apply(a2, i2)), a2;
        }
        function S(a2) {
          for (var t2 = 1; t2 < arguments.length; t2++) {
            var n2 = null != arguments[t2] ? arguments[t2] : {};
            t2 % 2 ? C(Object(n2), true).forEach(function(t3) {
              var e2, i2;
              e2 = a2, i2 = n2[t3 = t3], (t3 = D(t3)) in e2 ? Object.defineProperty(e2, t3, { value: i2, enumerable: true, configurable: true, writable: true }) : e2[t3] = i2;
            }) : Object.getOwnPropertyDescriptors ? Object.defineProperties(a2, Object.getOwnPropertyDescriptors(n2)) : C(Object(n2)).forEach(function(t3) {
              Object.defineProperty(a2, t3, Object.getOwnPropertyDescriptor(n2, t3));
            });
          }
          return a2;
        }
        function D(t2) {
          t2 = function(t3, e2) {
            if ("object" != typeof t3 || !t3) return t3;
            var i2 = t3[Symbol.toPrimitive];
            if (void 0 === i2) return ("string" === e2 ? String : Number)(t3);
            if ("object" != typeof (i2 = i2.call(t3, e2 || "default"))) return i2;
            throw new TypeError("@@toPrimitive must return a primitive value.");
          }(t2, "string");
          return "symbol" == typeof t2 ? t2 : t2 + "";
        }
        function j(t2) {
          return (j = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function(t3) {
            return typeof t3;
          } : function(t3) {
            return t3 && "function" == typeof Symbol && t3.constructor === Symbol && t3 !== Symbol.prototype ? "symbol" : typeof t3;
          })(t2);
        }
        function A(t2, e2) {
          for (var i2 = 0; i2 < e2.length; i2++) {
            var a2 = e2[i2];
            a2.enumerable = a2.enumerable || false, a2.configurable = true, "value" in a2 && (a2.writable = true), Object.defineProperty(t2, D(a2.key), a2);
          }
        }
        function P(t2) {
          return function(t3) {
            if (Array.isArray(t3)) return a(t3);
          }(t2) || function(t3) {
            if ("undefined" != typeof Symbol && null != t3[Symbol.iterator] || null != t3["@@iterator"]) return Array.from(t3);
          }(t2) || function(t3, e2) {
            var i2;
            if (t3) return "string" == typeof t3 ? a(t3, e2) : "Map" === (i2 = "Object" === (i2 = Object.prototype.toString.call(t3).slice(8, -1)) && t3.constructor ? t3.constructor.name : i2) || "Set" === i2 ? Array.from(t3) : "Arguments" === i2 || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(i2) ? a(t3, e2) : void 0;
          }(t2) || function() {
            throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
          }();
        }
        function a(t2, e2) {
          (null == e2 || e2 > t2.length) && (e2 = t2.length);
          for (var i2 = 0, a2 = new Array(e2); i2 < e2; i2++) a2[i2] = t2[i2];
          return a2;
        }
        var t = "undefined" != typeof window && void 0 !== window.document, h = t ? window : {}, e = !(!t || !h.document.documentElement) && "ontouchstart" in h.document.documentElement, i = t && "PointerEvent" in h, c = "cropper", I = "all", U = "crop", q = "move", $ = "zoom", B = "e", k = "w", O = "s", T = "n", E = "ne", W = "nw", H = "se", N = "sw", Q = "".concat(c, "-crop"), K = "".concat(c, "-disabled"), L = "".concat(c, "-hidden"), Z = "".concat(c, "-hide"), G = "".concat(c, "-invisible"), n = "".concat(c, "-modal"), V = "".concat(c, "-move"), d = "".concat(c, "Action"), m = "".concat(c, "Preview"), F = "crop", J = "move", _ = "none", tt = "crop", et = "cropend", it = "cropmove", at = "cropstart", nt = "dblclick", ot = i ? "pointerdown" : e ? "touchstart" : "mousedown", ht = i ? "pointermove" : e ? "touchmove" : "mousemove", rt = i ? "pointerup pointercancel" : e ? "touchend touchcancel" : "mouseup", st = "zoom", ct = "image/jpeg", dt = /^e|w|s|n|se|sw|ne|nw|all|crop|move|zoom$/, lt = /^data:/, pt = /^data:image\/jpeg;base64,/, mt = /^img|canvas$/i, ut = { viewMode: 0, dragMode: F, initialAspectRatio: NaN, aspectRatio: NaN, data: null, preview: "", responsive: true, restore: true, checkCrossOrigin: true, checkOrientation: true, modal: true, guides: true, center: true, highlight: true, background: true, autoCrop: true, autoCropArea: 0.8, movable: true, rotatable: true, scalable: true, zoomable: true, zoomOnTouch: true, zoomOnWheel: true, wheelZoomRatio: 0.1, cropBoxMovable: true, cropBoxResizable: true, toggleDragModeOnDblclick: true, minCanvasWidth: 0, minCanvasHeight: 0, minCropBoxWidth: 0, minCropBoxHeight: 0, minContainerWidth: 200, minContainerHeight: 100, ready: null, cropstart: null, cropmove: null, cropend: null, crop: null, zoom: null }, gt = Number.isNaN || h.isNaN;
        function p(t2) {
          return "number" == typeof t2 && !gt(t2);
        }
        function ft(t2) {
          return 0 < t2 && t2 < 1 / 0;
        }
        function vt(t2) {
          return void 0 === t2;
        }
        function o(t2) {
          return "object" === j(t2) && null !== t2;
        }
        var wt = Object.prototype.hasOwnProperty;
        function u(t2) {
          if (!o(t2)) return false;
          try {
            var e2 = t2.constructor, i2 = e2.prototype;
            return e2 && i2 && wt.call(i2, "isPrototypeOf");
          } catch (t3) {
            return false;
          }
        }
        function l(t2) {
          return "function" == typeof t2;
        }
        var bt = Array.prototype.slice;
        function yt(t2) {
          return Array.from ? Array.from(t2) : bt.call(t2);
        }
        function z(i2, a2) {
          return i2 && l(a2) && (Array.isArray(i2) || p(i2.length) ? yt(i2).forEach(function(t2, e2) {
            a2.call(i2, t2, e2, i2);
          }) : o(i2) && Object.keys(i2).forEach(function(t2) {
            a2.call(i2, i2[t2], t2, i2);
          })), i2;
        }
        var g = Object.assign || function(i2) {
          for (var t2 = arguments.length, e2 = new Array(1 < t2 ? t2 - 1 : 0), a2 = 1; a2 < t2; a2++) e2[a2 - 1] = arguments[a2];
          return o(i2) && 0 < e2.length && e2.forEach(function(e3) {
            o(e3) && Object.keys(e3).forEach(function(t3) {
              i2[t3] = e3[t3];
            });
          }), i2;
        }, xt = /\.\d*(?:0|9){12}\d*$/;
        function Y(t2, e2) {
          e2 = 1 < arguments.length && void 0 !== e2 ? e2 : 1e11;
          return xt.test(t2) ? Math.round(t2 * e2) / e2 : t2;
        }
        var Mt = /^width|height|left|top|marginLeft|marginTop$/;
        function f(t2, e2) {
          var i2 = t2.style;
          z(e2, function(t3, e3) {
            Mt.test(e3) && p(t3) && (t3 = "".concat(t3, "px")), i2[e3] = t3;
          });
        }
        function v(t2, e2) {
          var i2;
          e2 && (p(t2.length) ? z(t2, function(t3) {
            v(t3, e2);
          }) : t2.classList ? t2.classList.add(e2) : (i2 = t2.className.trim()) ? i2.indexOf(e2) < 0 && (t2.className = "".concat(i2, " ").concat(e2)) : t2.className = e2);
        }
        function X(t2, e2) {
          e2 && (p(t2.length) ? z(t2, function(t3) {
            X(t3, e2);
          }) : t2.classList ? t2.classList.remove(e2) : 0 <= t2.className.indexOf(e2) && (t2.className = t2.className.replace(e2, "")));
        }
        function r(t2, e2, i2) {
          e2 && (p(t2.length) ? z(t2, function(t3) {
            r(t3, e2, i2);
          }) : (i2 ? v : X)(t2, e2));
        }
        var Ct = /([a-z\d])([A-Z])/g;
        function Dt(t2) {
          return t2.replace(Ct, "$1-$2").toLowerCase();
        }
        function Bt(t2, e2) {
          return o(t2[e2]) ? t2[e2] : t2.dataset ? t2.dataset[e2] : t2.getAttribute("data-".concat(Dt(e2)));
        }
        function w(t2, e2, i2) {
          o(i2) ? t2[e2] = i2 : t2.dataset ? t2.dataset[e2] = i2 : t2.setAttribute("data-".concat(Dt(e2)), i2);
        }
        var kt, Ot, Tt = /\s\s*/, Et = (Ot = false, t && (kt = false, i = function() {
        }, e = Object.defineProperty({}, "once", { get: function() {
          return Ot = true, kt;
        }, set: function(t2) {
          kt = t2;
        } }), h.addEventListener("test", i, e), h.removeEventListener("test", i, e)), Ot);
        function s(i2, t2, a2, e2) {
          var n2 = 3 < arguments.length && void 0 !== e2 ? e2 : {}, o2 = a2;
          t2.trim().split(Tt).forEach(function(t3) {
            var e3;
            Et || (e3 = i2.listeners) && e3[t3] && e3[t3][a2] && (o2 = e3[t3][a2], delete e3[t3][a2], 0 === Object.keys(e3[t3]).length && delete e3[t3], 0 === Object.keys(e3).length) && delete i2.listeners, i2.removeEventListener(t3, o2, n2);
          });
        }
        function b(o2, t2, h2, e2) {
          var r2 = 3 < arguments.length && void 0 !== e2 ? e2 : {}, s2 = h2;
          t2.trim().split(Tt).forEach(function(a2) {
            var t3, n2;
            r2.once && !Et && (t3 = o2.listeners, s2 = function() {
              delete n2[a2][h2], o2.removeEventListener(a2, s2, r2);
              for (var t4 = arguments.length, e3 = new Array(t4), i2 = 0; i2 < t4; i2++) e3[i2] = arguments[i2];
              h2.apply(o2, e3);
            }, (n2 = void 0 === t3 ? {} : t3)[a2] || (n2[a2] = {}), n2[a2][h2] && o2.removeEventListener(a2, n2[a2][h2], r2), n2[a2][h2] = s2, o2.listeners = n2), o2.addEventListener(a2, s2, r2);
          });
        }
        function y(t2, e2, i2) {
          var a2;
          return l(Event) && l(CustomEvent) ? a2 = new CustomEvent(e2, { detail: i2, bubbles: true, cancelable: true }) : (a2 = document.createEvent("CustomEvent")).initCustomEvent(e2, true, true, i2), t2.dispatchEvent(a2);
        }
        function Wt(t2) {
          t2 = t2.getBoundingClientRect();
          return { left: t2.left + (window.pageXOffset - document.documentElement.clientLeft), top: t2.top + (window.pageYOffset - document.documentElement.clientTop) };
        }
        var Ht = h.location, Nt = /^(\w+:)\/\/([^:/?#]*):?(\d*)/i;
        function Lt(t2) {
          t2 = t2.match(Nt);
          return null !== t2 && (t2[1] !== Ht.protocol || t2[2] !== Ht.hostname || t2[3] !== Ht.port);
        }
        function zt(t2) {
          var e2 = "timestamp=".concat((/* @__PURE__ */ new Date()).getTime());
          return t2 + (-1 === t2.indexOf("?") ? "?" : "&") + e2;
        }
        function x(t2) {
          var e2 = t2.rotate, i2 = t2.scaleX, a2 = t2.scaleY, n2 = t2.translateX, t2 = t2.translateY, o2 = [], n2 = (p(n2) && 0 !== n2 && o2.push("translateX(".concat(n2, "px)")), p(t2) && 0 !== t2 && o2.push("translateY(".concat(t2, "px)")), p(e2) && 0 !== e2 && o2.push("rotate(".concat(e2, "deg)")), p(i2) && 1 !== i2 && o2.push("scaleX(".concat(i2, ")")), p(a2) && 1 !== a2 && o2.push("scaleY(".concat(a2, ")")), o2.length ? o2.join(" ") : "none");
          return { WebkitTransform: n2, msTransform: n2, transform: n2 };
        }
        function M(t2, e2) {
          var i2 = t2.pageX, t2 = t2.pageY, a2 = { endX: i2, endY: t2 };
          return e2 ? a2 : S({ startX: i2, startY: t2 }, a2);
        }
        function R(t2, e2) {
          var i2, a2 = t2.aspectRatio, n2 = t2.height, t2 = t2.width, e2 = 1 < arguments.length && void 0 !== e2 ? e2 : "contain", o2 = ft(t2), h2 = ft(n2);
          return o2 && h2 ? (i2 = n2 * a2, "contain" === e2 && t2 < i2 || "cover" === e2 && i2 < t2 ? n2 = t2 / a2 : t2 = n2 * a2) : o2 ? n2 = t2 / a2 : h2 && (t2 = n2 * a2), { width: t2, height: n2 };
        }
        var Yt = String.fromCharCode;
        var Xt = /^data:.*,/;
        function Rt(t2) {
          var e2, i2, a2, n2, o2, h2, r2, s2 = new DataView(t2);
          try {
            if (255 === s2.getUint8(0) && 216 === s2.getUint8(1)) for (var c2 = s2.byteLength, d2 = 2; d2 + 1 < c2; ) {
              if (255 === s2.getUint8(d2) && 225 === s2.getUint8(d2 + 1)) {
                i2 = d2;
                break;
              }
              d2 += 1;
            }
            if (a2 = i2 && (n2 = i2 + 10, "Exif" === function(t3, e3, i3) {
              var a3 = "";
              i3 += e3;
              for (var n3 = e3; n3 < i3; n3 += 1) a3 += Yt(t3.getUint8(n3));
              return a3;
            }(s2, i2 + 4, 4)) && ((r2 = 18761 === (o2 = s2.getUint16(n2))) || 19789 === o2) && 42 === s2.getUint16(n2 + 2, r2) && 8 <= (h2 = s2.getUint32(n2 + 4, r2)) ? n2 + h2 : a2) {
              for (var l2, p2 = s2.getUint16(a2, r2), m2 = 0; m2 < p2; m2 += 1) if (l2 = a2 + 12 * m2 + 2, 274 === s2.getUint16(l2, r2)) {
                l2 += 8, e2 = s2.getUint16(l2, r2), s2.setUint16(l2, 1, r2);
                break;
              }
            }
          } catch (t3) {
            e2 = 1;
          }
          return e2;
        }
        var t = { render: function() {
          this.initContainer(), this.initCanvas(), this.initCropBox(), this.renderCanvas(), this.cropped && this.renderCropBox();
        }, initContainer: function() {
          var t2 = this.element, e2 = this.options, i2 = this.container, a2 = this.cropper, n2 = Number(e2.minContainerWidth), e2 = Number(e2.minContainerHeight), n2 = (v(a2, L), X(t2, L), { width: Math.max(i2.offsetWidth, 0 <= n2 ? n2 : 200), height: Math.max(i2.offsetHeight, 0 <= e2 ? e2 : 100) });
          f(a2, { width: (this.containerData = n2).width, height: n2.height }), v(t2, L), X(a2, L);
        }, initCanvas: function() {
          var t2 = this.containerData, e2 = this.imageData, i2 = this.options.viewMode, a2 = Math.abs(e2.rotate) % 180 == 90, n2 = a2 ? e2.naturalHeight : e2.naturalWidth, a2 = a2 ? e2.naturalWidth : e2.naturalHeight, e2 = n2 / a2, o2 = t2.width, h2 = t2.height, e2 = (t2.height * e2 > t2.width ? 3 === i2 ? o2 = t2.height * e2 : h2 = t2.width / e2 : 3 === i2 ? h2 = t2.width / e2 : o2 = t2.height * e2, { aspectRatio: e2, naturalWidth: n2, naturalHeight: a2, width: o2, height: h2 });
          this.canvasData = e2, this.limited = 1 === i2 || 2 === i2, this.limitCanvas(true, true), e2.width = Math.min(Math.max(e2.width, e2.minWidth), e2.maxWidth), e2.height = Math.min(Math.max(e2.height, e2.minHeight), e2.maxHeight), e2.left = (t2.width - e2.width) / 2, e2.top = (t2.height - e2.height) / 2, e2.oldLeft = e2.left, e2.oldTop = e2.top, this.initialCanvasData = g({}, e2);
        }, limitCanvas: function(t2, e2) {
          var i2 = this.options, a2 = this.containerData, n2 = this.canvasData, o2 = this.cropBoxData, h2 = i2.viewMode, r2 = n2.aspectRatio, s2 = this.cropped && o2;
          t2 && (t2 = Number(i2.minCanvasWidth) || 0, i2 = Number(i2.minCanvasHeight) || 0, 1 < h2 ? (t2 = Math.max(t2, a2.width), i2 = Math.max(i2, a2.height), 3 === h2 && (t2 < i2 * r2 ? t2 = i2 * r2 : i2 = t2 / r2)) : 0 < h2 && (t2 ? t2 = Math.max(t2, s2 ? o2.width : 0) : i2 ? i2 = Math.max(i2, s2 ? o2.height : 0) : s2 && ((t2 = o2.width) < (i2 = o2.height) * r2 ? t2 = i2 * r2 : i2 = t2 / r2)), t2 = (r2 = R({ aspectRatio: r2, width: t2, height: i2 })).width, i2 = r2.height, n2.minWidth = t2, n2.minHeight = i2, n2.maxWidth = 1 / 0, n2.maxHeight = 1 / 0), e2 && ((s2 ? 0 : 1) < h2 ? (r2 = a2.width - n2.width, t2 = a2.height - n2.height, n2.minLeft = Math.min(0, r2), n2.minTop = Math.min(0, t2), n2.maxLeft = Math.max(0, r2), n2.maxTop = Math.max(0, t2), s2 && this.limited && (n2.minLeft = Math.min(o2.left, o2.left + (o2.width - n2.width)), n2.minTop = Math.min(o2.top, o2.top + (o2.height - n2.height)), n2.maxLeft = o2.left, n2.maxTop = o2.top, 2 === h2) && (n2.width >= a2.width && (n2.minLeft = Math.min(0, r2), n2.maxLeft = Math.max(0, r2)), n2.height >= a2.height) && (n2.minTop = Math.min(0, t2), n2.maxTop = Math.max(0, t2))) : (n2.minLeft = -n2.width, n2.minTop = -n2.height, n2.maxLeft = a2.width, n2.maxTop = a2.height));
        }, renderCanvas: function(t2, e2) {
          var i2, a2, n2, o2, h2 = this.canvasData, r2 = this.imageData;
          e2 && (e2 = { width: r2.naturalWidth * Math.abs(r2.scaleX || 1), height: r2.naturalHeight * Math.abs(r2.scaleY || 1), degree: r2.rotate || 0 }, r2 = e2.width, o2 = e2.height, e2 = e2.degree, i2 = 90 == (e2 = Math.abs(e2) % 180) ? { width: o2, height: r2 } : (a2 = e2 % 90 * Math.PI / 180, i2 = Math.sin(a2), n2 = r2 * (a2 = Math.cos(a2)) + o2 * i2, r2 = r2 * i2 + o2 * a2, 90 < e2 ? { width: r2, height: n2 } : { width: n2, height: r2 }), a2 = h2.width * ((o2 = i2.width) / h2.naturalWidth), n2 = h2.height * ((e2 = i2.height) / h2.naturalHeight), h2.left -= (a2 - h2.width) / 2, h2.top -= (n2 - h2.height) / 2, h2.width = a2, h2.height = n2, h2.aspectRatio = o2 / e2, h2.naturalWidth = o2, h2.naturalHeight = e2, this.limitCanvas(true, false)), (h2.width > h2.maxWidth || h2.width < h2.minWidth) && (h2.left = h2.oldLeft), (h2.height > h2.maxHeight || h2.height < h2.minHeight) && (h2.top = h2.oldTop), h2.width = Math.min(Math.max(h2.width, h2.minWidth), h2.maxWidth), h2.height = Math.min(Math.max(h2.height, h2.minHeight), h2.maxHeight), this.limitCanvas(false, true), h2.left = Math.min(Math.max(h2.left, h2.minLeft), h2.maxLeft), h2.top = Math.min(Math.max(h2.top, h2.minTop), h2.maxTop), h2.oldLeft = h2.left, h2.oldTop = h2.top, f(this.canvas, g({ width: h2.width, height: h2.height }, x({ translateX: h2.left, translateY: h2.top }))), this.renderImage(t2), this.cropped && this.limited && this.limitCropBox(true, true);
        }, renderImage: function(t2) {
          var e2 = this.canvasData, i2 = this.imageData, a2 = i2.naturalWidth * (e2.width / e2.naturalWidth), n2 = i2.naturalHeight * (e2.height / e2.naturalHeight);
          g(i2, { width: a2, height: n2, left: (e2.width - a2) / 2, top: (e2.height - n2) / 2 }), f(this.image, g({ width: i2.width, height: i2.height }, x(g({ translateX: i2.left, translateY: i2.top }, i2)))), t2 && this.output();
        }, initCropBox: function() {
          var t2 = this.options, e2 = this.canvasData, i2 = t2.aspectRatio || t2.initialAspectRatio, t2 = Number(t2.autoCropArea) || 0.8, a2 = { width: e2.width, height: e2.height };
          i2 && (e2.height * i2 > e2.width ? a2.height = a2.width / i2 : a2.width = a2.height * i2), this.cropBoxData = a2, this.limitCropBox(true, true), a2.width = Math.min(Math.max(a2.width, a2.minWidth), a2.maxWidth), a2.height = Math.min(Math.max(a2.height, a2.minHeight), a2.maxHeight), a2.width = Math.max(a2.minWidth, a2.width * t2), a2.height = Math.max(a2.minHeight, a2.height * t2), a2.left = e2.left + (e2.width - a2.width) / 2, a2.top = e2.top + (e2.height - a2.height) / 2, a2.oldLeft = a2.left, a2.oldTop = a2.top, this.initialCropBoxData = g({}, a2);
        }, limitCropBox: function(t2, e2) {
          var i2, a2, n2 = this.options, o2 = this.containerData, h2 = this.canvasData, r2 = this.cropBoxData, s2 = this.limited, c2 = n2.aspectRatio;
          t2 && (t2 = Number(n2.minCropBoxWidth) || 0, n2 = Number(n2.minCropBoxHeight) || 0, i2 = s2 ? Math.min(o2.width, h2.width, h2.width + h2.left, o2.width - h2.left) : o2.width, a2 = s2 ? Math.min(o2.height, h2.height, h2.height + h2.top, o2.height - h2.top) : o2.height, t2 = Math.min(t2, o2.width), n2 = Math.min(n2, o2.height), c2 && (t2 && n2 ? t2 < n2 * c2 ? n2 = t2 / c2 : t2 = n2 * c2 : t2 ? n2 = t2 / c2 : n2 && (t2 = n2 * c2), i2 < a2 * c2 ? a2 = i2 / c2 : i2 = a2 * c2), r2.minWidth = Math.min(t2, i2), r2.minHeight = Math.min(n2, a2), r2.maxWidth = i2, r2.maxHeight = a2), e2 && (s2 ? (r2.minLeft = Math.max(0, h2.left), r2.minTop = Math.max(0, h2.top), r2.maxLeft = Math.min(o2.width, h2.left + h2.width) - r2.width, r2.maxTop = Math.min(o2.height, h2.top + h2.height) - r2.height) : (r2.minLeft = 0, r2.minTop = 0, r2.maxLeft = o2.width - r2.width, r2.maxTop = o2.height - r2.height));
        }, renderCropBox: function() {
          var t2 = this.options, e2 = this.containerData, i2 = this.cropBoxData;
          (i2.width > i2.maxWidth || i2.width < i2.minWidth) && (i2.left = i2.oldLeft), (i2.height > i2.maxHeight || i2.height < i2.minHeight) && (i2.top = i2.oldTop), i2.width = Math.min(Math.max(i2.width, i2.minWidth), i2.maxWidth), i2.height = Math.min(Math.max(i2.height, i2.minHeight), i2.maxHeight), this.limitCropBox(false, true), i2.left = Math.min(Math.max(i2.left, i2.minLeft), i2.maxLeft), i2.top = Math.min(Math.max(i2.top, i2.minTop), i2.maxTop), i2.oldLeft = i2.left, i2.oldTop = i2.top, t2.movable && t2.cropBoxMovable && w(this.face, d, i2.width >= e2.width && i2.height >= e2.height ? q : I), f(this.cropBox, g({ width: i2.width, height: i2.height }, x({ translateX: i2.left, translateY: i2.top }))), this.cropped && this.limited && this.limitCanvas(true, true), this.disabled || this.output();
        }, output: function() {
          this.preview(), y(this.element, tt, this.getData());
        } }, i = { initPreview: function() {
          var t2 = this.element, i2 = this.crossOrigin, e2 = this.options.preview, a2 = i2 ? this.crossOriginUrl : this.url, n2 = t2.alt || "The image to preview", o2 = document.createElement("img");
          i2 && (o2.crossOrigin = i2), o2.src = a2, o2.alt = n2, this.viewBox.appendChild(o2), this.viewBoxImage = o2, e2 && ("string" == typeof (o2 = e2) ? o2 = t2.ownerDocument.querySelectorAll(e2) : e2.querySelector && (o2 = [e2]), z(this.previews = o2, function(t3) {
            var e3 = document.createElement("img");
            w(t3, m, { width: t3.offsetWidth, height: t3.offsetHeight, html: t3.innerHTML }), i2 && (e3.crossOrigin = i2), e3.src = a2, e3.alt = n2, e3.style.cssText = 'display:block;width:100%;height:auto;min-width:0!important;min-height:0!important;max-width:none!important;max-height:none!important;image-orientation:0deg!important;"', t3.innerHTML = "", t3.appendChild(e3);
          }));
        }, resetPreview: function() {
          z(this.previews, function(e2) {
            var i2 = Bt(e2, m), i2 = (f(e2, { width: i2.width, height: i2.height }), e2.innerHTML = i2.html, e2), e2 = m;
            if (o(i2[e2])) try {
              delete i2[e2];
            } catch (t2) {
              i2[e2] = void 0;
            }
            else if (i2.dataset) try {
              delete i2.dataset[e2];
            } catch (t2) {
              i2.dataset[e2] = void 0;
            }
            else i2.removeAttribute("data-".concat(Dt(e2)));
          });
        }, preview: function() {
          var h2 = this.imageData, t2 = this.canvasData, e2 = this.cropBoxData, r2 = e2.width, s2 = e2.height, c2 = h2.width, d2 = h2.height, l2 = e2.left - t2.left - h2.left, p2 = e2.top - t2.top - h2.top;
          this.cropped && !this.disabled && (f(this.viewBoxImage, g({ width: c2, height: d2 }, x(g({ translateX: -l2, translateY: -p2 }, h2)))), z(this.previews, function(t3) {
            var e3 = Bt(t3, m), i2 = e3.width, e3 = e3.height, a2 = i2, n2 = e3, o2 = 1;
            r2 && (n2 = s2 * (o2 = i2 / r2)), s2 && e3 < n2 && (a2 = r2 * (o2 = e3 / s2), n2 = e3), f(t3, { width: a2, height: n2 }), f(t3.getElementsByTagName("img")[0], g({ width: c2 * o2, height: d2 * o2 }, x(g({ translateX: -l2 * o2, translateY: -p2 * o2 }, h2))));
          }));
        } }, e = { bind: function() {
          var t2 = this.element, e2 = this.options, i2 = this.cropper;
          l(e2.cropstart) && b(t2, at, e2.cropstart), l(e2.cropmove) && b(t2, it, e2.cropmove), l(e2.cropend) && b(t2, et, e2.cropend), l(e2.crop) && b(t2, tt, e2.crop), l(e2.zoom) && b(t2, st, e2.zoom), b(i2, ot, this.onCropStart = this.cropStart.bind(this)), e2.zoomable && e2.zoomOnWheel && b(i2, "wheel", this.onWheel = this.wheel.bind(this), { passive: false, capture: true }), e2.toggleDragModeOnDblclick && b(i2, nt, this.onDblclick = this.dblclick.bind(this)), b(t2.ownerDocument, ht, this.onCropMove = this.cropMove.bind(this)), b(t2.ownerDocument, rt, this.onCropEnd = this.cropEnd.bind(this)), e2.responsive && b(window, "resize", this.onResize = this.resize.bind(this));
        }, unbind: function() {
          var t2 = this.element, e2 = this.options, i2 = this.cropper;
          l(e2.cropstart) && s(t2, at, e2.cropstart), l(e2.cropmove) && s(t2, it, e2.cropmove), l(e2.cropend) && s(t2, et, e2.cropend), l(e2.crop) && s(t2, tt, e2.crop), l(e2.zoom) && s(t2, st, e2.zoom), s(i2, ot, this.onCropStart), e2.zoomable && e2.zoomOnWheel && s(i2, "wheel", this.onWheel, { passive: false, capture: true }), e2.toggleDragModeOnDblclick && s(i2, nt, this.onDblclick), s(t2.ownerDocument, ht, this.onCropMove), s(t2.ownerDocument, rt, this.onCropEnd), e2.responsive && s(window, "resize", this.onResize);
        } }, St = { resize: function() {
          var t2, e2, i2, a2, n2, o2, h2;
          this.disabled || (t2 = this.options, a2 = this.container, e2 = this.containerData, i2 = a2.offsetWidth / e2.width, a2 = a2.offsetHeight / e2.height, 1 != (n2 = Math.abs(i2 - 1) > Math.abs(a2 - 1) ? i2 : a2) && (t2.restore && (o2 = this.getCanvasData(), h2 = this.getCropBoxData()), this.render(), t2.restore) && (this.setCanvasData(z(o2, function(t3, e3) {
            o2[e3] = t3 * n2;
          })), this.setCropBoxData(z(h2, function(t3, e3) {
            h2[e3] = t3 * n2;
          }))));
        }, dblclick: function() {
          var t2, e2;
          this.disabled || this.options.dragMode === _ || this.setDragMode((t2 = this.dragBox, e2 = Q, (t2.classList ? t2.classList.contains(e2) : -1 < t2.className.indexOf(e2)) ? J : F));
        }, wheel: function(t2) {
          var e2 = this, i2 = Number(this.options.wheelZoomRatio) || 0.1, a2 = 1;
          this.disabled || (t2.preventDefault(), this.wheeling) || (this.wheeling = true, setTimeout(function() {
            e2.wheeling = false;
          }, 50), t2.deltaY ? a2 = 0 < t2.deltaY ? 1 : -1 : t2.wheelDelta ? a2 = -t2.wheelDelta / 120 : t2.detail && (a2 = 0 < t2.detail ? 1 : -1), this.zoom(-a2 * i2, t2));
        }, cropStart: function(t2) {
          var e2, i2 = t2.buttons, a2 = t2.button;
          this.disabled || ("mousedown" === t2.type || "pointerdown" === t2.type && "mouse" === t2.pointerType) && (p(i2) && 1 !== i2 || p(a2) && 0 !== a2 || t2.ctrlKey) || (i2 = this.options, e2 = this.pointers, t2.changedTouches ? z(t2.changedTouches, function(t3) {
            e2[t3.identifier] = M(t3);
          }) : e2[t2.pointerId || 0] = M(t2), a2 = 1 < Object.keys(e2).length && i2.zoomable && i2.zoomOnTouch ? $ : Bt(t2.target, d), dt.test(a2) && false !== y(this.element, at, { originalEvent: t2, action: a2 }) && (t2.preventDefault(), this.action = a2, this.cropping = false, a2 === U) && (this.cropping = true, v(this.dragBox, n)));
        }, cropMove: function(t2) {
          var e2, i2 = this.action;
          !this.disabled && i2 && (e2 = this.pointers, t2.preventDefault(), false !== y(this.element, it, { originalEvent: t2, action: i2 })) && (t2.changedTouches ? z(t2.changedTouches, function(t3) {
            g(e2[t3.identifier] || {}, M(t3, true));
          }) : g(e2[t2.pointerId || 0] || {}, M(t2, true)), this.change(t2));
        }, cropEnd: function(t2) {
          var e2, i2;
          this.disabled || (e2 = this.action, i2 = this.pointers, t2.changedTouches ? z(t2.changedTouches, function(t3) {
            delete i2[t3.identifier];
          }) : delete i2[t2.pointerId || 0], e2 && (t2.preventDefault(), Object.keys(i2).length || (this.action = ""), this.cropping && (this.cropping = false, r(this.dragBox, n, this.cropped && this.options.modal)), y(this.element, et, { originalEvent: t2, action: e2 })));
        } }, jt = { change: function(t2) {
          function e2(t3) {
            switch (t3) {
              case B:
                f2 + D2.x > y2 && (D2.x = y2 - f2);
                break;
              case k:
                p2 + D2.x < w2 && (D2.x = w2 - p2);
                break;
              case T:
                m2 + D2.y < b2 && (D2.y = b2 - m2);
                break;
              case O:
                v2 + D2.y > x2 && (D2.y = x2 - v2);
            }
          }
          var i2, a2, o2, n2 = this.options, h2 = this.canvasData, r2 = this.containerData, s2 = this.cropBoxData, c2 = this.pointers, d2 = this.action, l2 = n2.aspectRatio, p2 = s2.left, m2 = s2.top, u2 = s2.width, g2 = s2.height, f2 = p2 + u2, v2 = m2 + g2, w2 = 0, b2 = 0, y2 = r2.width, x2 = r2.height, M2 = true, C2 = (!l2 && t2.shiftKey && (l2 = u2 && g2 ? u2 / g2 : 1), this.limited && (w2 = s2.minLeft, b2 = s2.minTop, y2 = w2 + Math.min(r2.width, h2.width, h2.left + h2.width), x2 = b2 + Math.min(r2.height, h2.height, h2.top + h2.height)), c2[Object.keys(c2)[0]]), D2 = { x: C2.endX - C2.startX, y: C2.endY - C2.startY };
          switch (d2) {
            case I:
              p2 += D2.x, m2 += D2.y;
              break;
            case B:
              0 <= D2.x && (y2 <= f2 || l2 && (m2 <= b2 || x2 <= v2)) ? M2 = false : (e2(B), (u2 += D2.x) < 0 && (d2 = k, p2 -= u2 = -u2), l2 && (m2 += (s2.height - (g2 = u2 / l2)) / 2));
              break;
            case T:
              D2.y <= 0 && (m2 <= b2 || l2 && (p2 <= w2 || y2 <= f2)) ? M2 = false : (e2(T), g2 -= D2.y, m2 += D2.y, g2 < 0 && (d2 = O, m2 -= g2 = -g2), l2 && (p2 += (s2.width - (u2 = g2 * l2)) / 2));
              break;
            case k:
              D2.x <= 0 && (p2 <= w2 || l2 && (m2 <= b2 || x2 <= v2)) ? M2 = false : (e2(k), u2 -= D2.x, p2 += D2.x, u2 < 0 && (d2 = B, p2 -= u2 = -u2), l2 && (m2 += (s2.height - (g2 = u2 / l2)) / 2));
              break;
            case O:
              0 <= D2.y && (x2 <= v2 || l2 && (p2 <= w2 || y2 <= f2)) ? M2 = false : (e2(O), (g2 += D2.y) < 0 && (d2 = T, m2 -= g2 = -g2), l2 && (p2 += (s2.width - (u2 = g2 * l2)) / 2));
              break;
            case E:
              if (l2) {
                if (D2.y <= 0 && (m2 <= b2 || y2 <= f2)) {
                  M2 = false;
                  break;
                }
                e2(T), g2 -= D2.y, m2 += D2.y, u2 = g2 * l2;
              } else e2(T), e2(B), !(0 <= D2.x) || f2 < y2 ? u2 += D2.x : D2.y <= 0 && m2 <= b2 && (M2 = false), (!(D2.y <= 0) || b2 < m2) && (g2 -= D2.y, m2 += D2.y);
              u2 < 0 && g2 < 0 ? (d2 = N, m2 -= g2 = -g2, p2 -= u2 = -u2) : u2 < 0 ? (d2 = W, p2 -= u2 = -u2) : g2 < 0 && (d2 = H, m2 -= g2 = -g2);
              break;
            case W:
              if (l2) {
                if (D2.y <= 0 && (m2 <= b2 || p2 <= w2)) {
                  M2 = false;
                  break;
                }
                e2(T), g2 -= D2.y, m2 += D2.y, p2 += s2.width - (u2 = g2 * l2);
              } else e2(T), e2(k), !(D2.x <= 0) || w2 < p2 ? (u2 -= D2.x, p2 += D2.x) : D2.y <= 0 && m2 <= b2 && (M2 = false), (!(D2.y <= 0) || b2 < m2) && (g2 -= D2.y, m2 += D2.y);
              u2 < 0 && g2 < 0 ? (d2 = H, m2 -= g2 = -g2, p2 -= u2 = -u2) : u2 < 0 ? (d2 = E, p2 -= u2 = -u2) : g2 < 0 && (d2 = N, m2 -= g2 = -g2);
              break;
            case N:
              if (l2) {
                if (D2.x <= 0 && (p2 <= w2 || x2 <= v2)) {
                  M2 = false;
                  break;
                }
                e2(k), u2 -= D2.x, p2 += D2.x, g2 = u2 / l2;
              } else e2(O), e2(k), !(D2.x <= 0) || w2 < p2 ? (u2 -= D2.x, p2 += D2.x) : 0 <= D2.y && x2 <= v2 && (M2 = false), (!(0 <= D2.y) || v2 < x2) && (g2 += D2.y);
              u2 < 0 && g2 < 0 ? (d2 = E, m2 -= g2 = -g2, p2 -= u2 = -u2) : u2 < 0 ? (d2 = H, p2 -= u2 = -u2) : g2 < 0 && (d2 = W, m2 -= g2 = -g2);
              break;
            case H:
              if (l2) {
                if (0 <= D2.x && (y2 <= f2 || x2 <= v2)) {
                  M2 = false;
                  break;
                }
                e2(B), g2 = (u2 += D2.x) / l2;
              } else e2(O), e2(B), !(0 <= D2.x) || f2 < y2 ? u2 += D2.x : 0 <= D2.y && x2 <= v2 && (M2 = false), (!(0 <= D2.y) || v2 < x2) && (g2 += D2.y);
              u2 < 0 && g2 < 0 ? (d2 = W, m2 -= g2 = -g2, p2 -= u2 = -u2) : u2 < 0 ? (d2 = N, p2 -= u2 = -u2) : g2 < 0 && (d2 = E, m2 -= g2 = -g2);
              break;
            case q:
              this.move(D2.x, D2.y), M2 = false;
              break;
            case $:
              this.zoom((a2 = S({}, i2 = c2), o2 = 0, z(i2, function(n3, t3) {
                delete a2[t3], z(a2, function(t4) {
                  var e3 = Math.abs(n3.startX - t4.startX), i3 = Math.abs(n3.startY - t4.startY), a3 = Math.abs(n3.endX - t4.endX), t4 = Math.abs(n3.endY - t4.endY), e3 = Math.sqrt(e3 * e3 + i3 * i3), i3 = (Math.sqrt(a3 * a3 + t4 * t4) - e3) / e3;
                  Math.abs(i3) > Math.abs(o2) && (o2 = i3);
                });
              }), o2), t2), M2 = false;
              break;
            case U:
              D2.x && D2.y ? (i2 = Wt(this.cropper), p2 = C2.startX - i2.left, m2 = C2.startY - i2.top, u2 = s2.minWidth, g2 = s2.minHeight, 0 < D2.x ? d2 = 0 < D2.y ? H : E : D2.x < 0 && (p2 -= u2, d2 = 0 < D2.y ? N : W), D2.y < 0 && (m2 -= g2), this.cropped || (X(this.cropBox, L), this.cropped = true, this.limited && this.limitCropBox(true, true))) : M2 = false;
          }
          M2 && (s2.width = u2, s2.height = g2, s2.left = p2, s2.top = m2, this.action = d2, this.renderCropBox()), z(c2, function(t3) {
            t3.startX = t3.endX, t3.startY = t3.endY;
          });
        } }, At = { crop: function() {
          return !this.ready || this.cropped || this.disabled || (this.cropped = true, this.limitCropBox(true, true), this.options.modal && v(this.dragBox, n), X(this.cropBox, L), this.setCropBoxData(this.initialCropBoxData)), this;
        }, reset: function() {
          return this.ready && !this.disabled && (this.imageData = g({}, this.initialImageData), this.canvasData = g({}, this.initialCanvasData), this.cropBoxData = g({}, this.initialCropBoxData), this.renderCanvas(), this.cropped) && this.renderCropBox(), this;
        }, clear: function() {
          return this.cropped && !this.disabled && (g(this.cropBoxData, { left: 0, top: 0, width: 0, height: 0 }), this.cropped = false, this.renderCropBox(), this.limitCanvas(true, true), this.renderCanvas(), X(this.dragBox, n), v(this.cropBox, L)), this;
        }, replace: function(e2) {
          var t2 = 1 < arguments.length && void 0 !== arguments[1] && arguments[1];
          return !this.disabled && e2 && (this.isImg && (this.element.src = e2), t2 ? (this.url = e2, this.image.src = e2, this.ready && (this.viewBoxImage.src = e2, z(this.previews, function(t3) {
            t3.getElementsByTagName("img")[0].src = e2;
          }))) : (this.isImg && (this.replaced = true), this.options.data = null, this.uncreate(), this.load(e2))), this;
        }, enable: function() {
          return this.ready && this.disabled && (this.disabled = false, X(this.cropper, K)), this;
        }, disable: function() {
          return this.ready && !this.disabled && (this.disabled = true, v(this.cropper, K)), this;
        }, destroy: function() {
          var t2 = this.element;
          return t2[c] && (t2[c] = void 0, this.isImg && this.replaced && (t2.src = this.originalUrl), this.uncreate()), this;
        }, move: function(t2) {
          var e2 = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : t2, i2 = this.canvasData, a2 = i2.left, i2 = i2.top;
          return this.moveTo(vt(t2) ? t2 : a2 + Number(t2), vt(e2) ? e2 : i2 + Number(e2));
        }, moveTo: function(t2) {
          var e2 = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : t2, i2 = this.canvasData, a2 = false;
          return t2 = Number(t2), e2 = Number(e2), this.ready && !this.disabled && this.options.movable && (p(t2) && (i2.left = t2, a2 = true), p(e2) && (i2.top = e2, a2 = true), a2) && this.renderCanvas(true), this;
        }, zoom: function(t2, e2) {
          var i2 = this.canvasData;
          return t2 = Number(t2), this.zoomTo(i2.width * (t2 = t2 < 0 ? 1 / (1 - t2) : 1 + t2) / i2.naturalWidth, null, e2);
        }, zoomTo: function(t2, e2, i2) {
          var a2, n2, o2, h2 = this.options, r2 = this.canvasData, s2 = r2.width, c2 = r2.height, d2 = r2.naturalWidth, l2 = r2.naturalHeight;
          if (0 <= (t2 = Number(t2)) && this.ready && !this.disabled && h2.zoomable) {
            h2 = d2 * t2, l2 = l2 * t2;
            if (false === y(this.element, st, { ratio: t2, oldRatio: s2 / d2, originalEvent: i2 })) return this;
            i2 ? (t2 = this.pointers, d2 = Wt(this.cropper), t2 = t2 && Object.keys(t2).length ? (o2 = n2 = a2 = 0, z(t2, function(t3) {
              var e3 = t3.startX, t3 = t3.startY;
              a2 += e3, n2 += t3, o2 += 1;
            }), { pageX: a2 /= o2, pageY: n2 /= o2 }) : { pageX: i2.pageX, pageY: i2.pageY }, r2.left -= (h2 - s2) * ((t2.pageX - d2.left - r2.left) / s2), r2.top -= (l2 - c2) * ((t2.pageY - d2.top - r2.top) / c2)) : u(e2) && p(e2.x) && p(e2.y) ? (r2.left -= (h2 - s2) * ((e2.x - r2.left) / s2), r2.top -= (l2 - c2) * ((e2.y - r2.top) / c2)) : (r2.left -= (h2 - s2) / 2, r2.top -= (l2 - c2) / 2), r2.width = h2, r2.height = l2, this.renderCanvas(true);
          }
          return this;
        }, rotate: function(t2) {
          return this.rotateTo((this.imageData.rotate || 0) + Number(t2));
        }, rotateTo: function(t2) {
          return p(t2 = Number(t2)) && this.ready && !this.disabled && this.options.rotatable && (this.imageData.rotate = t2 % 360, this.renderCanvas(true, true)), this;
        }, scaleX: function(t2) {
          var e2 = this.imageData.scaleY;
          return this.scale(t2, p(e2) ? e2 : 1);
        }, scaleY: function(t2) {
          var e2 = this.imageData.scaleX;
          return this.scale(p(e2) ? e2 : 1, t2);
        }, scale: function(t2) {
          var e2 = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : t2, i2 = this.imageData, a2 = false;
          return t2 = Number(t2), e2 = Number(e2), this.ready && !this.disabled && this.options.scalable && (p(t2) && (i2.scaleX = t2, a2 = true), p(e2) && (i2.scaleY = e2, a2 = true), a2) && this.renderCanvas(true, true), this;
        }, getData: function() {
          var i2, a2, t2 = 0 < arguments.length && void 0 !== arguments[0] && arguments[0], e2 = this.options, n2 = this.imageData, o2 = this.canvasData, h2 = this.cropBoxData;
          return this.ready && this.cropped ? (i2 = { x: h2.left - o2.left, y: h2.top - o2.top, width: h2.width, height: h2.height }, a2 = n2.width / n2.naturalWidth, z(i2, function(t3, e3) {
            i2[e3] = t3 / a2;
          }), t2 && (o2 = Math.round(i2.y + i2.height), h2 = Math.round(i2.x + i2.width), i2.x = Math.round(i2.x), i2.y = Math.round(i2.y), i2.width = h2 - i2.x, i2.height = o2 - i2.y)) : i2 = { x: 0, y: 0, width: 0, height: 0 }, e2.rotatable && (i2.rotate = n2.rotate || 0), e2.scalable && (i2.scaleX = n2.scaleX || 1, i2.scaleY = n2.scaleY || 1), i2;
        }, setData: function(t2) {
          var e2, i2 = this.options, a2 = this.imageData, n2 = this.canvasData, o2 = {};
          return this.ready && !this.disabled && u(t2) && (e2 = false, i2.rotatable && p(t2.rotate) && t2.rotate !== a2.rotate && (a2.rotate = t2.rotate, e2 = true), i2.scalable && (p(t2.scaleX) && t2.scaleX !== a2.scaleX && (a2.scaleX = t2.scaleX, e2 = true), p(t2.scaleY)) && t2.scaleY !== a2.scaleY && (a2.scaleY = t2.scaleY, e2 = true), e2 && this.renderCanvas(true, true), i2 = a2.width / a2.naturalWidth, p(t2.x) && (o2.left = t2.x * i2 + n2.left), p(t2.y) && (o2.top = t2.y * i2 + n2.top), p(t2.width) && (o2.width = t2.width * i2), p(t2.height) && (o2.height = t2.height * i2), this.setCropBoxData(o2)), this;
        }, getContainerData: function() {
          return this.ready ? g({}, this.containerData) : {};
        }, getImageData: function() {
          return this.sized ? g({}, this.imageData) : {};
        }, getCanvasData: function() {
          var e2 = this.canvasData, i2 = {};
          return this.ready && z(["left", "top", "width", "height", "naturalWidth", "naturalHeight"], function(t2) {
            i2[t2] = e2[t2];
          }), i2;
        }, setCanvasData: function(t2) {
          var e2 = this.canvasData, i2 = e2.aspectRatio;
          return this.ready && !this.disabled && u(t2) && (p(t2.left) && (e2.left = t2.left), p(t2.top) && (e2.top = t2.top), p(t2.width) ? (e2.width = t2.width, e2.height = t2.width / i2) : p(t2.height) && (e2.height = t2.height, e2.width = t2.height * i2), this.renderCanvas(true)), this;
        }, getCropBoxData: function() {
          var t2, e2 = this.cropBoxData;
          return (t2 = this.ready && this.cropped ? { left: e2.left, top: e2.top, width: e2.width, height: e2.height } : t2) || {};
        }, setCropBoxData: function(t2) {
          var e2, i2, a2 = this.cropBoxData, n2 = this.options.aspectRatio;
          return this.ready && this.cropped && !this.disabled && u(t2) && (p(t2.left) && (a2.left = t2.left), p(t2.top) && (a2.top = t2.top), p(t2.width) && t2.width !== a2.width && (e2 = true, a2.width = t2.width), p(t2.height) && t2.height !== a2.height && (i2 = true, a2.height = t2.height), n2 && (e2 ? a2.height = a2.width / n2 : i2 && (a2.width = a2.height * n2)), this.renderCropBox()), this;
        }, getCroppedCanvas: function() {
          var t2, e2, i2, a2, n2, o2, h2, r2, s2, c2, d2, l2, p2, m2, u2, g2, f2, v2, w2, b2, y2, x2, M2, C2, D2, B2, k2, O2 = 0 < arguments.length && void 0 !== arguments[0] ? arguments[0] : {};
          return this.ready && window.HTMLCanvasElement ? (B2 = this.canvasData, u2 = this.image, l2 = this.imageData, a2 = B2, v2 = O2, g2 = l2.aspectRatio, e2 = l2.naturalWidth, n2 = l2.naturalHeight, c2 = void 0 === (c2 = l2.rotate) ? 0 : c2, d2 = void 0 === (d2 = l2.scaleX) ? 1 : d2, l2 = void 0 === (l2 = l2.scaleY) ? 1 : l2, i2 = a2.aspectRatio, r2 = a2.naturalWidth, a2 = a2.naturalHeight, h2 = void 0 === (h2 = v2.fillColor) ? "transparent" : h2, p2 = void 0 === (p2 = v2.imageSmoothingEnabled) || p2, m2 = void 0 === (m2 = v2.imageSmoothingQuality) ? "low" : m2, o2 = void 0 === (o2 = v2.maxWidth) ? 1 / 0 : o2, k2 = void 0 === (k2 = v2.maxHeight) ? 1 / 0 : k2, t2 = void 0 === (t2 = v2.minWidth) ? 0 : t2, v2 = void 0 === (v2 = v2.minHeight) ? 0 : v2, w2 = document.createElement("canvas"), f2 = w2.getContext("2d"), s2 = R({ aspectRatio: i2, width: o2, height: k2 }), i2 = R({ aspectRatio: i2, width: t2, height: v2 }, "cover"), r2 = Math.min(s2.width, Math.max(i2.width, r2)), s2 = Math.min(s2.height, Math.max(i2.height, a2)), i2 = R({ aspectRatio: g2, width: o2, height: k2 }), a2 = R({ aspectRatio: g2, width: t2, height: v2 }, "cover"), o2 = Math.min(i2.width, Math.max(a2.width, e2)), k2 = Math.min(i2.height, Math.max(a2.height, n2)), g2 = [-o2 / 2, -k2 / 2, o2, k2], w2.width = Y(r2), w2.height = Y(s2), f2.fillStyle = h2, f2.fillRect(0, 0, r2, s2), f2.save(), f2.translate(r2 / 2, s2 / 2), f2.rotate(c2 * Math.PI / 180), f2.scale(d2, l2), f2.imageSmoothingEnabled = p2, f2.imageSmoothingQuality = m2, f2.drawImage.apply(f2, [u2].concat(P(g2.map(function(t3) {
            return Math.floor(Y(t3));
          })))), f2.restore(), t2 = w2, this.cropped ? (e2 = (v2 = this.getData(O2.rounded)).x, i2 = v2.y, a2 = v2.width, n2 = v2.height, 1 != (o2 = t2.width / Math.floor(B2.naturalWidth)) && (e2 *= o2, i2 *= o2, a2 *= o2, n2 *= o2), h2 = R({ aspectRatio: k2 = a2 / n2, width: O2.maxWidth || 1 / 0, height: O2.maxHeight || 1 / 0 }), r2 = R({ aspectRatio: k2, width: O2.minWidth || 0, height: O2.minHeight || 0 }, "cover"), c2 = (s2 = R({ aspectRatio: k2, width: O2.width || (1 != o2 ? t2.width : a2), height: O2.height || (1 != o2 ? t2.height : n2) })).width, d2 = s2.height, c2 = Math.min(h2.width, Math.max(r2.width, c2)), d2 = Math.min(h2.height, Math.max(r2.height, d2)), p2 = (l2 = document.createElement("canvas")).getContext("2d"), l2.width = Y(c2), l2.height = Y(d2), p2.fillStyle = O2.fillColor || "transparent", p2.fillRect(0, 0, c2, d2), m2 = O2.imageSmoothingEnabled, u2 = O2.imageSmoothingQuality, p2.imageSmoothingEnabled = void 0 === m2 || m2, u2 && (p2.imageSmoothingQuality = u2), g2 = t2.width, f2 = t2.height, w2 = i2, (v2 = e2) <= -a2 || g2 < v2 ? C2 = x2 = b2 = v2 = 0 : v2 <= 0 ? (x2 = -v2, v2 = 0, C2 = b2 = Math.min(g2, a2 + v2)) : v2 <= g2 && (x2 = 0, C2 = b2 = Math.min(a2, g2 - v2)), b2 <= 0 || w2 <= -n2 || f2 < w2 ? D2 = M2 = y2 = w2 = 0 : w2 <= 0 ? (M2 = -w2, w2 = 0, D2 = y2 = Math.min(f2, n2 + w2)) : w2 <= f2 && (M2 = 0, D2 = y2 = Math.min(n2, f2 - w2)), B2 = [v2, w2, b2, y2], 0 < C2 && 0 < D2 && B2.push(x2 * (k2 = c2 / a2), M2 * k2, C2 * k2, D2 * k2), p2.drawImage.apply(p2, [t2].concat(P(B2.map(function(t3) {
            return Math.floor(Y(t3));
          })))), l2) : t2) : null;
        }, setAspectRatio: function(t2) {
          var e2 = this.options;
          return this.disabled || vt(t2) || (e2.aspectRatio = Math.max(0, t2) || NaN, this.ready && (this.initCropBox(), this.cropped) && this.renderCropBox()), this;
        }, setDragMode: function(t2) {
          var e2, i2, a2 = this.options, n2 = this.dragBox, o2 = this.face;
          return this.ready && !this.disabled && (i2 = a2.movable && t2 === J, a2.dragMode = t2 = (e2 = t2 === F) || i2 ? t2 : _, w(n2, d, t2), r(n2, Q, e2), r(n2, V, i2), a2.cropBoxMovable || (w(o2, d, t2), r(o2, Q, e2), r(o2, V, i2))), this;
        } }, Pt = h.Cropper, It = function() {
          function n2(t3) {
            var e3 = 1 < arguments.length && void 0 !== arguments[1] ? arguments[1] : {}, i3 = this, a2 = n2;
            if (!(i3 instanceof a2)) throw new TypeError("Cannot call a class as a function");
            if (!t3 || !mt.test(t3.tagName)) throw new Error("The first argument is required and must be an <img> or <canvas> element.");
            this.element = t3, this.options = g({}, ut, u(e3) && e3), this.cropped = false, this.disabled = false, this.pointers = {}, this.ready = false, this.reloading = false, this.replaced = false, this.sized = false, this.sizing = false, this.init();
          }
          return t2 = n2, i2 = [{ key: "noConflict", value: function() {
            return window.Cropper = Pt, n2;
          } }, { key: "setDefaults", value: function(t3) {
            g(ut, u(t3) && t3);
          } }], (e2 = [{ key: "init", value: function() {
            var t3, e3 = this.element, i3 = e3.tagName.toLowerCase();
            if (!e3[c]) {
              if (e3[c] = this, "img" === i3) {
                if (this.isImg = true, t3 = e3.getAttribute("src") || "", !(this.originalUrl = t3)) return;
                t3 = e3.src;
              } else "canvas" === i3 && window.HTMLCanvasElement && (t3 = e3.toDataURL());
              this.load(t3);
            }
          } }, { key: "load", value: function(t3) {
            var e3, i3, a2, n3, o2, h2, r2 = this;
            t3 && (this.url = t3, this.imageData = {}, e3 = this.element, (i3 = this.options).rotatable || i3.scalable || (i3.checkOrientation = false), i3.checkOrientation && window.ArrayBuffer ? lt.test(t3) ? pt.test(t3) ? this.read((h2 = (h2 = t3).replace(Xt, ""), a2 = atob(h2), h2 = new ArrayBuffer(a2.length), z(n3 = new Uint8Array(h2), function(t4, e4) {
              n3[e4] = a2.charCodeAt(e4);
            }), h2)) : this.clone() : (o2 = new XMLHttpRequest(), h2 = this.clone.bind(this), this.reloading = true, (this.xhr = o2).onabort = h2, o2.onerror = h2, o2.ontimeout = h2, o2.onprogress = function() {
              o2.getResponseHeader("content-type") !== ct && o2.abort();
            }, o2.onload = function() {
              r2.read(o2.response);
            }, o2.onloadend = function() {
              r2.reloading = false, r2.xhr = null;
            }, i3.checkCrossOrigin && Lt(t3) && e3.crossOrigin && (t3 = zt(t3)), o2.open("GET", t3, true), o2.responseType = "arraybuffer", o2.withCredentials = "use-credentials" === e3.crossOrigin, o2.send()) : this.clone());
          } }, { key: "read", value: function(t3) {
            var e3 = this.options, i3 = this.imageData, a2 = Rt(t3), n3 = 0, o2 = 1, h2 = 1;
            1 < a2 && (this.url = function(t4, e4) {
              for (var i4 = [], a3 = new Uint8Array(t4); 0 < a3.length; ) i4.push(Yt.apply(null, yt(a3.subarray(0, 8192)))), a3 = a3.subarray(8192);
              return "data:".concat(e4, ";base64,").concat(btoa(i4.join("")));
            }(t3, ct), n3 = (t3 = function(t4) {
              var e4 = 0, i4 = 1, a3 = 1;
              switch (t4) {
                case 2:
                  i4 = -1;
                  break;
                case 3:
                  e4 = -180;
                  break;
                case 4:
                  a3 = -1;
                  break;
                case 5:
                  e4 = 90, a3 = -1;
                  break;
                case 6:
                  e4 = 90;
                  break;
                case 7:
                  e4 = 90, i4 = -1;
                  break;
                case 8:
                  e4 = -90;
              }
              return { rotate: e4, scaleX: i4, scaleY: a3 };
            }(a2)).rotate, o2 = t3.scaleX, h2 = t3.scaleY), e3.rotatable && (i3.rotate = n3), e3.scalable && (i3.scaleX = o2, i3.scaleY = h2), this.clone();
          } }, { key: "clone", value: function() {
            var t3 = this.element, e3 = this.url, i3 = t3.crossOrigin, a2 = e3, n3 = (this.options.checkCrossOrigin && Lt(e3) && (i3 = i3 || "anonymous", a2 = zt(e3)), this.crossOrigin = i3, this.crossOriginUrl = a2, document.createElement("img"));
            i3 && (n3.crossOrigin = i3), n3.src = a2 || e3, n3.alt = t3.alt || "The image to crop", (this.image = n3).onload = this.start.bind(this), n3.onerror = this.stop.bind(this), v(n3, Z), t3.parentNode.insertBefore(n3, t3.nextSibling);
          } }, { key: "start", value: function() {
            function t3(t4, e4) {
              g(a2.imageData, { naturalWidth: t4, naturalHeight: e4, aspectRatio: t4 / e4 }), a2.initialImageData = g({}, a2.imageData), a2.sizing = false, a2.sized = true, a2.build();
            }
            var e3, i3, a2 = this, n3 = this.image, o2 = (n3.onload = null, n3.onerror = null, this.sizing = true, h.navigator && /(?:iPad|iPhone|iPod).*?AppleWebKit/i.test(h.navigator.userAgent));
            n3.naturalWidth && !o2 ? t3(n3.naturalWidth, n3.naturalHeight) : (e3 = document.createElement("img"), i3 = document.body || document.documentElement, (this.sizingImage = e3).onload = function() {
              t3(e3.width, e3.height), o2 || i3.removeChild(e3);
            }, e3.src = n3.src, o2 || (e3.style.cssText = "left:0;max-height:none!important;max-width:none!important;min-height:0!important;min-width:0!important;opacity:0;position:absolute;top:0;z-index:-1;", i3.appendChild(e3)));
          } }, { key: "stop", value: function() {
            var t3 = this.image;
            t3.onload = null, t3.onerror = null, t3.parentNode.removeChild(t3), this.image = null;
          } }, { key: "build", value: function() {
            var t3, e3, i3, a2, n3, o2, h2, r2, s2;
            this.sized && !this.ready && (t3 = this.element, e3 = this.options, i3 = this.image, a2 = t3.parentNode, (n3 = document.createElement("div")).innerHTML = '<div class="cropper-container" touch-action="none"><div class="cropper-wrap-box"><div class="cropper-canvas"></div></div><div class="cropper-drag-box"></div><div class="cropper-crop-box"><span class="cropper-view-box"></span><span class="cropper-dashed dashed-h"></span><span class="cropper-dashed dashed-v"></span><span class="cropper-center"></span><span class="cropper-face"></span><span class="cropper-line line-e" data-cropper-action="e"></span><span class="cropper-line line-n" data-cropper-action="n"></span><span class="cropper-line line-w" data-cropper-action="w"></span><span class="cropper-line line-s" data-cropper-action="s"></span><span class="cropper-point point-e" data-cropper-action="e"></span><span class="cropper-point point-n" data-cropper-action="n"></span><span class="cropper-point point-w" data-cropper-action="w"></span><span class="cropper-point point-s" data-cropper-action="s"></span><span class="cropper-point point-ne" data-cropper-action="ne"></span><span class="cropper-point point-nw" data-cropper-action="nw"></span><span class="cropper-point point-sw" data-cropper-action="sw"></span><span class="cropper-point point-se" data-cropper-action="se"></span></div></div>', o2 = (n3 = n3.querySelector(".".concat(c, "-container"))).querySelector(".".concat(c, "-canvas")), h2 = n3.querySelector(".".concat(c, "-drag-box")), s2 = (r2 = n3.querySelector(".".concat(c, "-crop-box"))).querySelector(".".concat(c, "-face")), this.container = a2, this.cropper = n3, this.canvas = o2, this.dragBox = h2, this.cropBox = r2, this.viewBox = n3.querySelector(".".concat(c, "-view-box")), this.face = s2, o2.appendChild(i3), v(t3, L), a2.insertBefore(n3, t3.nextSibling), X(i3, Z), this.initPreview(), this.bind(), e3.initialAspectRatio = Math.max(0, e3.initialAspectRatio) || NaN, e3.aspectRatio = Math.max(0, e3.aspectRatio) || NaN, e3.viewMode = Math.max(0, Math.min(3, Math.round(e3.viewMode))) || 0, v(r2, L), e3.guides || v(r2.getElementsByClassName("".concat(c, "-dashed")), L), e3.center || v(r2.getElementsByClassName("".concat(c, "-center")), L), e3.background && v(n3, "".concat(c, "-bg")), e3.highlight || v(s2, G), e3.cropBoxMovable && (v(s2, V), w(s2, d, I)), e3.cropBoxResizable || (v(r2.getElementsByClassName("".concat(c, "-line")), L), v(r2.getElementsByClassName("".concat(c, "-point")), L)), this.render(), this.ready = true, this.setDragMode(e3.dragMode), e3.autoCrop && this.crop(), this.setData(e3.data), l(e3.ready) && b(t3, "ready", e3.ready, { once: true }), y(t3, "ready"));
          } }, { key: "unbuild", value: function() {
            var t3;
            this.ready && (this.ready = false, this.unbind(), this.resetPreview(), (t3 = this.cropper.parentNode) && t3.removeChild(this.cropper), X(this.element, L));
          } }, { key: "uncreate", value: function() {
            this.ready ? (this.unbuild(), this.ready = false, this.cropped = false) : this.sizing ? (this.sizingImage.onload = null, this.sizing = false, this.sized = false) : this.reloading ? (this.xhr.onabort = null, this.xhr.abort()) : this.image && this.stop();
          } }]) && A(t2.prototype, e2), i2 && A(t2, i2), Object.defineProperty(t2, "prototype", { writable: false }), t2;
          var t2, e2, i2;
        }();
        return g(It.prototype, t, i, e, St, jt, At), It;
      });
    }
  });

  // ../deps/phoenix_html/priv/static/phoenix_html.js
  (function() {
    var PolyfillEvent = eventConstructor();
    function eventConstructor() {
      if (typeof window.CustomEvent === "function") return window.CustomEvent;
      function CustomEvent2(event, params) {
        params = params || { bubbles: false, cancelable: false, detail: void 0 };
        var evt = document.createEvent("CustomEvent");
        evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
        return evt;
      }
      CustomEvent2.prototype = window.Event.prototype;
      return CustomEvent2;
    }
    function buildHiddenInput(name, value) {
      var input = document.createElement("input");
      input.type = "hidden";
      input.name = name;
      input.value = value;
      return input;
    }
    function handleClick(element, targetModifierKey) {
      var to = element.getAttribute("data-to"), method = buildHiddenInput("_method", element.getAttribute("data-method")), csrf = buildHiddenInput("_csrf_token", element.getAttribute("data-csrf")), form = document.createElement("form"), submit = document.createElement("input"), target = element.getAttribute("target");
      form.method = element.getAttribute("data-method") === "get" ? "get" : "post";
      form.action = to;
      form.style.display = "none";
      if (target) form.target = target;
      else if (targetModifierKey) form.target = "_blank";
      form.appendChild(csrf);
      form.appendChild(method);
      document.body.appendChild(form);
      submit.type = "submit";
      form.appendChild(submit);
      submit.click();
    }
    window.addEventListener("click", function(e) {
      var element = e.target;
      if (e.defaultPrevented) return;
      while (element && element.getAttribute) {
        var phoenixLinkEvent = new PolyfillEvent("phoenix.link.click", {
          "bubbles": true,
          "cancelable": true
        });
        if (!element.dispatchEvent(phoenixLinkEvent)) {
          e.preventDefault();
          e.stopImmediatePropagation();
          return false;
        }
        if (element.getAttribute("data-method") && element.getAttribute("data-to")) {
          handleClick(element, e.metaKey || e.shiftKey);
          e.preventDefault();
          return false;
        } else {
          element = element.parentNode;
        }
      }
    }, false);
    window.addEventListener("phoenix.link.click", function(e) {
      var message = e.target.getAttribute("data-confirm");
      if (message && !window.confirm(message)) {
        e.preventDefault();
      }
    }, false);
  })();

  // ../deps/phoenix/priv/static/phoenix.mjs
  var closure = (value) => {
    if (typeof value === "function") {
      return value;
    } else {
      let closure22 = function() {
        return value;
      };
      return closure22;
    }
  };
  var globalSelf = typeof self !== "undefined" ? self : null;
  var phxWindow = typeof window !== "undefined" ? window : null;
  var global = globalSelf || phxWindow || global;
  var DEFAULT_VSN = "2.0.0";
  var SOCKET_STATES = { connecting: 0, open: 1, closing: 2, closed: 3 };
  var MAX_LONGPOLL_BATCH_SIZE = 100;
  var DEFAULT_TIMEOUT = 1e4;
  var WS_CLOSE_NORMAL = 1e3;
  var CHANNEL_STATES = {
    closed: "closed",
    errored: "errored",
    joined: "joined",
    joining: "joining",
    leaving: "leaving"
  };
  var CHANNEL_EVENTS = {
    close: "phx_close",
    error: "phx_error",
    join: "phx_join",
    reply: "phx_reply",
    leave: "phx_leave"
  };
  var TRANSPORTS = {
    longpoll: "longpoll",
    websocket: "websocket"
  };
  var XHR_STATES = {
    complete: 4
  };
  var Push = class {
    constructor(channel, event, payload, timeout) {
      this.channel = channel;
      this.event = event;
      this.payload = payload || function() {
        return {};
      };
      this.receivedResp = null;
      this.timeout = timeout;
      this.timeoutTimer = null;
      this.recHooks = [];
      this.sent = false;
    }
    /**
     *
     * @param {number} timeout
     */
    resend(timeout) {
      this.timeout = timeout;
      this.reset();
      this.send();
    }
    /**
     *
     */
    send() {
      if (this.hasReceived("timeout")) {
        return;
      }
      this.startTimeout();
      this.sent = true;
      this.channel.socket.push({
        topic: this.channel.topic,
        event: this.event,
        payload: this.payload(),
        ref: this.ref,
        join_ref: this.channel.joinRef()
      });
    }
    /**
     *
     * @param {*} status
     * @param {*} callback
     */
    receive(status, callback) {
      if (this.hasReceived(status)) {
        callback(this.receivedResp.response);
      }
      this.recHooks.push({ status, callback });
      return this;
    }
    /**
     * @private
     */
    reset() {
      this.cancelRefEvent();
      this.ref = null;
      this.refEvent = null;
      this.receivedResp = null;
      this.sent = false;
    }
    /**
     * @private
     */
    matchReceive({ status, response, _ref }) {
      this.recHooks.filter((h) => h.status === status).forEach((h) => h.callback(response));
    }
    /**
     * @private
     */
    cancelRefEvent() {
      if (!this.refEvent) {
        return;
      }
      this.channel.off(this.refEvent);
    }
    /**
     * @private
     */
    cancelTimeout() {
      clearTimeout(this.timeoutTimer);
      this.timeoutTimer = null;
    }
    /**
     * @private
     */
    startTimeout() {
      if (this.timeoutTimer) {
        this.cancelTimeout();
      }
      this.ref = this.channel.socket.makeRef();
      this.refEvent = this.channel.replyEventName(this.ref);
      this.channel.on(this.refEvent, (payload) => {
        this.cancelRefEvent();
        this.cancelTimeout();
        this.receivedResp = payload;
        this.matchReceive(payload);
      });
      this.timeoutTimer = setTimeout(() => {
        this.trigger("timeout", {});
      }, this.timeout);
    }
    /**
     * @private
     */
    hasReceived(status) {
      return this.receivedResp && this.receivedResp.status === status;
    }
    /**
     * @private
     */
    trigger(status, response) {
      this.channel.trigger(this.refEvent, { status, response });
    }
  };
  var Timer = class {
    constructor(callback, timerCalc) {
      this.callback = callback;
      this.timerCalc = timerCalc;
      this.timer = null;
      this.tries = 0;
    }
    reset() {
      this.tries = 0;
      clearTimeout(this.timer);
    }
    /**
     * Cancels any previous scheduleTimeout and schedules callback
     */
    scheduleTimeout() {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => {
        this.tries = this.tries + 1;
        this.callback();
      }, this.timerCalc(this.tries + 1));
    }
  };
  var Channel = class {
    constructor(topic, params, socket) {
      this.state = CHANNEL_STATES.closed;
      this.topic = topic;
      this.params = closure(params || {});
      this.socket = socket;
      this.bindings = [];
      this.bindingRef = 0;
      this.timeout = this.socket.timeout;
      this.joinedOnce = false;
      this.joinPush = new Push(this, CHANNEL_EVENTS.join, this.params, this.timeout);
      this.pushBuffer = [];
      this.stateChangeRefs = [];
      this.rejoinTimer = new Timer(() => {
        if (this.socket.isConnected()) {
          this.rejoin();
        }
      }, this.socket.rejoinAfterMs);
      this.stateChangeRefs.push(this.socket.onError(() => this.rejoinTimer.reset()));
      this.stateChangeRefs.push(
        this.socket.onOpen(() => {
          this.rejoinTimer.reset();
          if (this.isErrored()) {
            this.rejoin();
          }
        })
      );
      this.joinPush.receive("ok", () => {
        this.state = CHANNEL_STATES.joined;
        this.rejoinTimer.reset();
        this.pushBuffer.forEach((pushEvent) => pushEvent.send());
        this.pushBuffer = [];
      });
      this.joinPush.receive("error", () => {
        this.state = CHANNEL_STATES.errored;
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.onClose(() => {
        this.rejoinTimer.reset();
        if (this.socket.hasLogger()) this.socket.log("channel", `close ${this.topic} ${this.joinRef()}`);
        this.state = CHANNEL_STATES.closed;
        this.socket.remove(this);
      });
      this.onError((reason) => {
        if (this.socket.hasLogger()) this.socket.log("channel", `error ${this.topic}`, reason);
        if (this.isJoining()) {
          this.joinPush.reset();
        }
        this.state = CHANNEL_STATES.errored;
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.joinPush.receive("timeout", () => {
        if (this.socket.hasLogger()) this.socket.log("channel", `timeout ${this.topic} (${this.joinRef()})`, this.joinPush.timeout);
        let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure({}), this.timeout);
        leavePush.send();
        this.state = CHANNEL_STATES.errored;
        this.joinPush.reset();
        if (this.socket.isConnected()) {
          this.rejoinTimer.scheduleTimeout();
        }
      });
      this.on(CHANNEL_EVENTS.reply, (payload, ref) => {
        this.trigger(this.replyEventName(ref), payload);
      });
    }
    /**
     * Join the channel
     * @param {integer} timeout
     * @returns {Push}
     */
    join(timeout = this.timeout) {
      if (this.joinedOnce) {
        throw new Error("tried to join multiple times. 'join' can only be called a single time per channel instance");
      } else {
        this.timeout = timeout;
        this.joinedOnce = true;
        this.rejoin();
        return this.joinPush;
      }
    }
    /**
     * Hook into channel close
     * @param {Function} callback
     */
    onClose(callback) {
      this.on(CHANNEL_EVENTS.close, callback);
    }
    /**
     * Hook into channel errors
     * @param {Function} callback
     */
    onError(callback) {
      return this.on(CHANNEL_EVENTS.error, (reason) => callback(reason));
    }
    /**
     * Subscribes on channel events
     *
     * Subscription returns a ref counter, which can be used later to
     * unsubscribe the exact event listener
     *
     * @example
     * const ref1 = channel.on("event", do_stuff)
     * const ref2 = channel.on("event", do_other_stuff)
     * channel.off("event", ref1)
     * // Since unsubscription, do_stuff won't fire,
     * // while do_other_stuff will keep firing on the "event"
     *
     * @param {string} event
     * @param {Function} callback
     * @returns {integer} ref
     */
    on(event, callback) {
      let ref = this.bindingRef++;
      this.bindings.push({ event, ref, callback });
      return ref;
    }
    /**
     * Unsubscribes off of channel events
     *
     * Use the ref returned from a channel.on() to unsubscribe one
     * handler, or pass nothing for the ref to unsubscribe all
     * handlers for the given event.
     *
     * @example
     * // Unsubscribe the do_stuff handler
     * const ref1 = channel.on("event", do_stuff)
     * channel.off("event", ref1)
     *
     * // Unsubscribe all handlers from event
     * channel.off("event")
     *
     * @param {string} event
     * @param {integer} ref
     */
    off(event, ref) {
      this.bindings = this.bindings.filter((bind) => {
        return !(bind.event === event && (typeof ref === "undefined" || ref === bind.ref));
      });
    }
    /**
     * @private
     */
    canPush() {
      return this.socket.isConnected() && this.isJoined();
    }
    /**
     * Sends a message `event` to phoenix with the payload `payload`.
     * Phoenix receives this in the `handle_in(event, payload, socket)`
     * function. if phoenix replies or it times out (default 10000ms),
     * then optionally the reply can be received.
     *
     * @example
     * channel.push("event")
     *   .receive("ok", payload => console.log("phoenix replied:", payload))
     *   .receive("error", err => console.log("phoenix errored", err))
     *   .receive("timeout", () => console.log("timed out pushing"))
     * @param {string} event
     * @param {Object} payload
     * @param {number} [timeout]
     * @returns {Push}
     */
    push(event, payload, timeout = this.timeout) {
      payload = payload || {};
      if (!this.joinedOnce) {
        throw new Error(`tried to push '${event}' to '${this.topic}' before joining. Use channel.join() before pushing events`);
      }
      let pushEvent = new Push(this, event, function() {
        return payload;
      }, timeout);
      if (this.canPush()) {
        pushEvent.send();
      } else {
        pushEvent.startTimeout();
        this.pushBuffer.push(pushEvent);
      }
      return pushEvent;
    }
    /** Leaves the channel
     *
     * Unsubscribes from server events, and
     * instructs channel to terminate on server
     *
     * Triggers onClose() hooks
     *
     * To receive leave acknowledgements, use the `receive`
     * hook to bind to the server ack, ie:
     *
     * @example
     * channel.leave().receive("ok", () => alert("left!") )
     *
     * @param {integer} timeout
     * @returns {Push}
     */
    leave(timeout = this.timeout) {
      this.rejoinTimer.reset();
      this.joinPush.cancelTimeout();
      this.state = CHANNEL_STATES.leaving;
      let onClose = () => {
        if (this.socket.hasLogger()) this.socket.log("channel", `leave ${this.topic}`);
        this.trigger(CHANNEL_EVENTS.close, "leave");
      };
      let leavePush = new Push(this, CHANNEL_EVENTS.leave, closure({}), timeout);
      leavePush.receive("ok", () => onClose()).receive("timeout", () => onClose());
      leavePush.send();
      if (!this.canPush()) {
        leavePush.trigger("ok", {});
      }
      return leavePush;
    }
    /**
     * Overridable message hook
     *
     * Receives all events for specialized message handling
     * before dispatching to the channel callbacks.
     *
     * Must return the payload, modified or unmodified
     * @param {string} event
     * @param {Object} payload
     * @param {integer} ref
     * @returns {Object}
     */
    onMessage(_event, payload, _ref) {
      return payload;
    }
    /**
     * @private
     */
    isMember(topic, event, payload, joinRef) {
      if (this.topic !== topic) {
        return false;
      }
      if (joinRef && joinRef !== this.joinRef()) {
        if (this.socket.hasLogger()) this.socket.log("channel", "dropping outdated message", { topic, event, payload, joinRef });
        return false;
      } else {
        return true;
      }
    }
    /**
     * @private
     */
    joinRef() {
      return this.joinPush.ref;
    }
    /**
     * @private
     */
    rejoin(timeout = this.timeout) {
      if (this.isLeaving()) {
        return;
      }
      this.socket.leaveOpenTopic(this.topic);
      this.state = CHANNEL_STATES.joining;
      this.joinPush.resend(timeout);
    }
    /**
     * @private
     */
    trigger(event, payload, ref, joinRef) {
      let handledPayload = this.onMessage(event, payload, ref, joinRef);
      if (payload && !handledPayload) {
        throw new Error("channel onMessage callbacks must return the payload, modified or unmodified");
      }
      let eventBindings = this.bindings.filter((bind) => bind.event === event);
      for (let i = 0; i < eventBindings.length; i++) {
        let bind = eventBindings[i];
        bind.callback(handledPayload, ref, joinRef || this.joinRef());
      }
    }
    /**
     * @private
     */
    replyEventName(ref) {
      return `chan_reply_${ref}`;
    }
    /**
     * @private
     */
    isClosed() {
      return this.state === CHANNEL_STATES.closed;
    }
    /**
     * @private
     */
    isErrored() {
      return this.state === CHANNEL_STATES.errored;
    }
    /**
     * @private
     */
    isJoined() {
      return this.state === CHANNEL_STATES.joined;
    }
    /**
     * @private
     */
    isJoining() {
      return this.state === CHANNEL_STATES.joining;
    }
    /**
     * @private
     */
    isLeaving() {
      return this.state === CHANNEL_STATES.leaving;
    }
  };
  var Ajax = class {
    static request(method, endPoint, accept, body, timeout, ontimeout, callback) {
      if (global.XDomainRequest) {
        let req = new global.XDomainRequest();
        return this.xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback);
      } else {
        let req = new global.XMLHttpRequest();
        return this.xhrRequest(req, method, endPoint, accept, body, timeout, ontimeout, callback);
      }
    }
    static xdomainRequest(req, method, endPoint, body, timeout, ontimeout, callback) {
      req.timeout = timeout;
      req.open(method, endPoint);
      req.onload = () => {
        let response = this.parseJSON(req.responseText);
        callback && callback(response);
      };
      if (ontimeout) {
        req.ontimeout = ontimeout;
      }
      req.onprogress = () => {
      };
      req.send(body);
      return req;
    }
    static xhrRequest(req, method, endPoint, accept, body, timeout, ontimeout, callback) {
      req.open(method, endPoint, true);
      req.timeout = timeout;
      req.setRequestHeader("Content-Type", accept);
      req.onerror = () => callback && callback(null);
      req.onreadystatechange = () => {
        if (req.readyState === XHR_STATES.complete && callback) {
          let response = this.parseJSON(req.responseText);
          callback(response);
        }
      };
      if (ontimeout) {
        req.ontimeout = ontimeout;
      }
      req.send(body);
      return req;
    }
    static parseJSON(resp) {
      if (!resp || resp === "") {
        return null;
      }
      try {
        return JSON.parse(resp);
      } catch (e) {
        console && console.log("failed to parse JSON response", resp);
        return null;
      }
    }
    static serialize(obj, parentKey) {
      let queryStr = [];
      for (var key in obj) {
        if (!Object.prototype.hasOwnProperty.call(obj, key)) {
          continue;
        }
        let paramKey = parentKey ? `${parentKey}[${key}]` : key;
        let paramVal = obj[key];
        if (typeof paramVal === "object") {
          queryStr.push(this.serialize(paramVal, paramKey));
        } else {
          queryStr.push(encodeURIComponent(paramKey) + "=" + encodeURIComponent(paramVal));
        }
      }
      return queryStr.join("&");
    }
    static appendParams(url, params) {
      if (Object.keys(params).length === 0) {
        return url;
      }
      let prefix = url.match(/\?/) ? "&" : "?";
      return `${url}${prefix}${this.serialize(params)}`;
    }
  };
  var arrayBufferToBase64 = (buffer) => {
    let binary = "";
    let bytes = new Uint8Array(buffer);
    let len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  };
  var LongPoll = class {
    constructor(endPoint) {
      this.endPoint = null;
      this.token = null;
      this.skipHeartbeat = true;
      this.reqs = /* @__PURE__ */ new Set();
      this.awaitingBatchAck = false;
      this.currentBatch = null;
      this.currentBatchTimer = null;
      this.batchBuffer = [];
      this.onopen = function() {
      };
      this.onerror = function() {
      };
      this.onmessage = function() {
      };
      this.onclose = function() {
      };
      this.pollEndpoint = this.normalizeEndpoint(endPoint);
      this.readyState = SOCKET_STATES.connecting;
      setTimeout(() => this.poll(), 0);
    }
    normalizeEndpoint(endPoint) {
      return endPoint.replace("ws://", "http://").replace("wss://", "https://").replace(new RegExp("(.*)/" + TRANSPORTS.websocket), "$1/" + TRANSPORTS.longpoll);
    }
    endpointURL() {
      return Ajax.appendParams(this.pollEndpoint, { token: this.token });
    }
    closeAndRetry(code, reason, wasClean) {
      this.close(code, reason, wasClean);
      this.readyState = SOCKET_STATES.connecting;
    }
    ontimeout() {
      this.onerror("timeout");
      this.closeAndRetry(1005, "timeout", false);
    }
    isActive() {
      return this.readyState === SOCKET_STATES.open || this.readyState === SOCKET_STATES.connecting;
    }
    poll() {
      this.ajax("GET", "application/json", null, () => this.ontimeout(), (resp) => {
        if (resp) {
          var { status, token, messages } = resp;
          this.token = token;
        } else {
          status = 0;
        }
        switch (status) {
          case 200:
            messages.forEach((msg) => {
              setTimeout(() => this.onmessage({ data: msg }), 0);
            });
            this.poll();
            break;
          case 204:
            this.poll();
            break;
          case 410:
            this.readyState = SOCKET_STATES.open;
            this.onopen({});
            this.poll();
            break;
          case 403:
            this.onerror(403);
            this.close(1008, "forbidden", false);
            break;
          case 0:
          case 500:
            this.onerror(500);
            this.closeAndRetry(1011, "internal server error", 500);
            break;
          default:
            throw new Error(`unhandled poll status ${status}`);
        }
      });
    }
    // we collect all pushes within the current event loop by
    // setTimeout 0, which optimizes back-to-back procedural
    // pushes against an empty buffer
    send(body) {
      if (typeof body !== "string") {
        body = arrayBufferToBase64(body);
      }
      if (this.currentBatch) {
        this.currentBatch.push(body);
      } else if (this.awaitingBatchAck) {
        this.batchBuffer.push(body);
      } else {
        this.currentBatch = [body];
        this.currentBatchTimer = setTimeout(() => {
          this.batchSend(this.currentBatch);
          this.currentBatch = null;
        }, 0);
      }
    }
    batchSend(messages, offset = 0) {
      this.awaitingBatchAck = true;
      const next = offset + MAX_LONGPOLL_BATCH_SIZE;
      const batch = messages.slice(offset, next);
      this.ajax("POST", "application/x-ndjson", batch.join("\n"), () => this.onerror("timeout"), (resp) => {
        if (!resp || resp.status !== 200) {
          this.awaitingBatchAck = false;
          this.onerror(resp && resp.status);
          this.closeAndRetry(1011, "internal server error", false);
        } else if (next < messages.length) {
          this.batchSend(messages, next);
        } else if (this.batchBuffer.length > 0) {
          this.batchSend(this.batchBuffer);
          this.batchBuffer = [];
        } else {
          this.awaitingBatchAck = false;
        }
      });
    }
    close(code, reason, wasClean) {
      for (let req of this.reqs) {
        req.abort();
      }
      this.readyState = SOCKET_STATES.closed;
      let opts = Object.assign({ code: 1e3, reason: void 0, wasClean: true }, { code, reason, wasClean });
      this.batchBuffer = [];
      clearTimeout(this.currentBatchTimer);
      this.currentBatchTimer = null;
      if (typeof CloseEvent !== "undefined") {
        this.onclose(new CloseEvent("close", opts));
      } else {
        this.onclose(opts);
      }
    }
    ajax(method, contentType, body, onCallerTimeout, callback) {
      let req;
      let ontimeout = () => {
        this.reqs.delete(req);
        onCallerTimeout();
      };
      req = Ajax.request(method, this.endpointURL(), contentType, body, this.timeout, ontimeout, (resp) => {
        this.reqs.delete(req);
        if (this.isActive()) {
          callback(resp);
        }
      });
      this.reqs.add(req);
    }
  };
  var serializer_default = {
    HEADER_LENGTH: 1,
    META_LENGTH: 4,
    KINDS: { push: 0, reply: 1, broadcast: 2 },
    encode(msg, callback) {
      if (msg.payload.constructor === ArrayBuffer) {
        return callback(this.binaryEncode(msg));
      } else {
        let payload = [msg.join_ref, msg.ref, msg.topic, msg.event, msg.payload];
        return callback(JSON.stringify(payload));
      }
    },
    decode(rawPayload, callback) {
      if (rawPayload.constructor === ArrayBuffer) {
        return callback(this.binaryDecode(rawPayload));
      } else {
        let [join_ref, ref, topic, event, payload] = JSON.parse(rawPayload);
        return callback({ join_ref, ref, topic, event, payload });
      }
    },
    // private
    binaryEncode(message) {
      let { join_ref, ref, event, topic, payload } = message;
      let metaLength = this.META_LENGTH + join_ref.length + ref.length + topic.length + event.length;
      let header = new ArrayBuffer(this.HEADER_LENGTH + metaLength);
      let view = new DataView(header);
      let offset = 0;
      view.setUint8(offset++, this.KINDS.push);
      view.setUint8(offset++, join_ref.length);
      view.setUint8(offset++, ref.length);
      view.setUint8(offset++, topic.length);
      view.setUint8(offset++, event.length);
      Array.from(join_ref, (char) => view.setUint8(offset++, char.charCodeAt(0)));
      Array.from(ref, (char) => view.setUint8(offset++, char.charCodeAt(0)));
      Array.from(topic, (char) => view.setUint8(offset++, char.charCodeAt(0)));
      Array.from(event, (char) => view.setUint8(offset++, char.charCodeAt(0)));
      var combined = new Uint8Array(header.byteLength + payload.byteLength);
      combined.set(new Uint8Array(header), 0);
      combined.set(new Uint8Array(payload), header.byteLength);
      return combined.buffer;
    },
    binaryDecode(buffer) {
      let view = new DataView(buffer);
      let kind = view.getUint8(0);
      let decoder = new TextDecoder();
      switch (kind) {
        case this.KINDS.push:
          return this.decodePush(buffer, view, decoder);
        case this.KINDS.reply:
          return this.decodeReply(buffer, view, decoder);
        case this.KINDS.broadcast:
          return this.decodeBroadcast(buffer, view, decoder);
      }
    },
    decodePush(buffer, view, decoder) {
      let joinRefSize = view.getUint8(1);
      let topicSize = view.getUint8(2);
      let eventSize = view.getUint8(3);
      let offset = this.HEADER_LENGTH + this.META_LENGTH - 1;
      let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
      offset = offset + joinRefSize;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      return { join_ref: joinRef, ref: null, topic, event, payload: data };
    },
    decodeReply(buffer, view, decoder) {
      let joinRefSize = view.getUint8(1);
      let refSize = view.getUint8(2);
      let topicSize = view.getUint8(3);
      let eventSize = view.getUint8(4);
      let offset = this.HEADER_LENGTH + this.META_LENGTH;
      let joinRef = decoder.decode(buffer.slice(offset, offset + joinRefSize));
      offset = offset + joinRefSize;
      let ref = decoder.decode(buffer.slice(offset, offset + refSize));
      offset = offset + refSize;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      let payload = { status: event, response: data };
      return { join_ref: joinRef, ref, topic, event: CHANNEL_EVENTS.reply, payload };
    },
    decodeBroadcast(buffer, view, decoder) {
      let topicSize = view.getUint8(1);
      let eventSize = view.getUint8(2);
      let offset = this.HEADER_LENGTH + 2;
      let topic = decoder.decode(buffer.slice(offset, offset + topicSize));
      offset = offset + topicSize;
      let event = decoder.decode(buffer.slice(offset, offset + eventSize));
      offset = offset + eventSize;
      let data = buffer.slice(offset, buffer.byteLength);
      return { join_ref: null, ref: null, topic, event, payload: data };
    }
  };
  var Socket = class {
    constructor(endPoint, opts = {}) {
      this.stateChangeCallbacks = { open: [], close: [], error: [], message: [] };
      this.channels = [];
      this.sendBuffer = [];
      this.ref = 0;
      this.timeout = opts.timeout || DEFAULT_TIMEOUT;
      this.transport = opts.transport || global.WebSocket || LongPoll;
      this.primaryPassedHealthCheck = false;
      this.longPollFallbackMs = opts.longPollFallbackMs;
      this.fallbackTimer = null;
      this.sessionStore = opts.sessionStorage || global && global.sessionStorage;
      this.establishedConnections = 0;
      this.defaultEncoder = serializer_default.encode.bind(serializer_default);
      this.defaultDecoder = serializer_default.decode.bind(serializer_default);
      this.closeWasClean = false;
      this.disconnecting = false;
      this.binaryType = opts.binaryType || "arraybuffer";
      this.connectClock = 1;
      if (this.transport !== LongPoll) {
        this.encode = opts.encode || this.defaultEncoder;
        this.decode = opts.decode || this.defaultDecoder;
      } else {
        this.encode = this.defaultEncoder;
        this.decode = this.defaultDecoder;
      }
      let awaitingConnectionOnPageShow = null;
      if (phxWindow && phxWindow.addEventListener) {
        phxWindow.addEventListener("pagehide", (_e) => {
          if (this.conn) {
            this.disconnect();
            awaitingConnectionOnPageShow = this.connectClock;
          }
        });
        phxWindow.addEventListener("pageshow", (_e) => {
          if (awaitingConnectionOnPageShow === this.connectClock) {
            awaitingConnectionOnPageShow = null;
            this.connect();
          }
        });
      }
      this.heartbeatIntervalMs = opts.heartbeatIntervalMs || 3e4;
      this.rejoinAfterMs = (tries) => {
        if (opts.rejoinAfterMs) {
          return opts.rejoinAfterMs(tries);
        } else {
          return [1e3, 2e3, 5e3][tries - 1] || 1e4;
        }
      };
      this.reconnectAfterMs = (tries) => {
        if (opts.reconnectAfterMs) {
          return opts.reconnectAfterMs(tries);
        } else {
          return [10, 50, 100, 150, 200, 250, 500, 1e3, 2e3][tries - 1] || 5e3;
        }
      };
      this.logger = opts.logger || null;
      if (!this.logger && opts.debug) {
        this.logger = (kind, msg, data) => {
          console.log(`${kind}: ${msg}`, data);
        };
      }
      this.longpollerTimeout = opts.longpollerTimeout || 2e4;
      this.params = closure(opts.params || {});
      this.endPoint = `${endPoint}/${TRANSPORTS.websocket}`;
      this.vsn = opts.vsn || DEFAULT_VSN;
      this.heartbeatTimeoutTimer = null;
      this.heartbeatTimer = null;
      this.pendingHeartbeatRef = null;
      this.reconnectTimer = new Timer(() => {
        this.teardown(() => this.connect());
      }, this.reconnectAfterMs);
    }
    /**
     * Returns the LongPoll transport reference
     */
    getLongPollTransport() {
      return LongPoll;
    }
    /**
     * Disconnects and replaces the active transport
     *
     * @param {Function} newTransport - The new transport class to instantiate
     *
     */
    replaceTransport(newTransport) {
      this.connectClock++;
      this.closeWasClean = true;
      clearTimeout(this.fallbackTimer);
      this.reconnectTimer.reset();
      if (this.conn) {
        this.conn.close();
        this.conn = null;
      }
      this.transport = newTransport;
    }
    /**
     * Returns the socket protocol
     *
     * @returns {string}
     */
    protocol() {
      return location.protocol.match(/^https/) ? "wss" : "ws";
    }
    /**
     * The fully qualified socket url
     *
     * @returns {string}
     */
    endPointURL() {
      let uri = Ajax.appendParams(
        Ajax.appendParams(this.endPoint, this.params()),
        { vsn: this.vsn }
      );
      if (uri.charAt(0) !== "/") {
        return uri;
      }
      if (uri.charAt(1) === "/") {
        return `${this.protocol()}:${uri}`;
      }
      return `${this.protocol()}://${location.host}${uri}`;
    }
    /**
     * Disconnects the socket
     *
     * See https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent#Status_codes for valid status codes.
     *
     * @param {Function} callback - Optional callback which is called after socket is disconnected.
     * @param {integer} code - A status code for disconnection (Optional).
     * @param {string} reason - A textual description of the reason to disconnect. (Optional)
     */
    disconnect(callback, code, reason) {
      this.connectClock++;
      this.disconnecting = true;
      this.closeWasClean = true;
      clearTimeout(this.fallbackTimer);
      this.reconnectTimer.reset();
      this.teardown(() => {
        this.disconnecting = false;
        callback && callback();
      }, code, reason);
    }
    /**
     *
     * @param {Object} params - The params to send when connecting, for example `{user_id: userToken}`
     *
     * Passing params to connect is deprecated; pass them in the Socket constructor instead:
     * `new Socket("/socket", {params: {user_id: userToken}})`.
     */
    connect(params) {
      if (params) {
        console && console.log("passing params to connect is deprecated. Instead pass :params to the Socket constructor");
        this.params = closure(params);
      }
      if (this.conn && !this.disconnecting) {
        return;
      }
      if (this.longPollFallbackMs && this.transport !== LongPoll) {
        this.connectWithFallback(LongPoll, this.longPollFallbackMs);
      } else {
        this.transportConnect();
      }
    }
    /**
     * Logs the message. Override `this.logger` for specialized logging. noops by default
     * @param {string} kind
     * @param {string} msg
     * @param {Object} data
     */
    log(kind, msg, data) {
      this.logger && this.logger(kind, msg, data);
    }
    /**
     * Returns true if a logger has been set on this socket.
     */
    hasLogger() {
      return this.logger !== null;
    }
    /**
     * Registers callbacks for connection open events
     *
     * @example socket.onOpen(function(){ console.info("the socket was opened") })
     *
     * @param {Function} callback
     */
    onOpen(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.open.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection close events
     * @param {Function} callback
     */
    onClose(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.close.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection error events
     *
     * @example socket.onError(function(error){ alert("An error occurred") })
     *
     * @param {Function} callback
     */
    onError(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.error.push([ref, callback]);
      return ref;
    }
    /**
     * Registers callbacks for connection message events
     * @param {Function} callback
     */
    onMessage(callback) {
      let ref = this.makeRef();
      this.stateChangeCallbacks.message.push([ref, callback]);
      return ref;
    }
    /**
     * Pings the server and invokes the callback with the RTT in milliseconds
     * @param {Function} callback
     *
     * Returns true if the ping was pushed or false if unable to be pushed.
     */
    ping(callback) {
      if (!this.isConnected()) {
        return false;
      }
      let ref = this.makeRef();
      let startTime = Date.now();
      this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref });
      let onMsgRef = this.onMessage((msg) => {
        if (msg.ref === ref) {
          this.off([onMsgRef]);
          callback(Date.now() - startTime);
        }
      });
      return true;
    }
    /**
     * @private
     */
    transportConnect() {
      this.connectClock++;
      this.closeWasClean = false;
      this.conn = new this.transport(this.endPointURL());
      this.conn.binaryType = this.binaryType;
      this.conn.timeout = this.longpollerTimeout;
      this.conn.onopen = () => this.onConnOpen();
      this.conn.onerror = (error) => this.onConnError(error);
      this.conn.onmessage = (event) => this.onConnMessage(event);
      this.conn.onclose = (event) => this.onConnClose(event);
    }
    getSession(key) {
      return this.sessionStore && this.sessionStore.getItem(key);
    }
    storeSession(key, val) {
      this.sessionStore && this.sessionStore.setItem(key, val);
    }
    connectWithFallback(fallbackTransport, fallbackThreshold = 2500) {
      clearTimeout(this.fallbackTimer);
      let established = false;
      let primaryTransport = true;
      let openRef, errorRef;
      let fallback = (reason) => {
        this.log("transport", `falling back to ${fallbackTransport.name}...`, reason);
        this.off([openRef, errorRef]);
        primaryTransport = false;
        this.replaceTransport(fallbackTransport);
        this.transportConnect();
      };
      if (this.getSession(`phx:fallback:${fallbackTransport.name}`)) {
        return fallback("memorized");
      }
      this.fallbackTimer = setTimeout(fallback, fallbackThreshold);
      errorRef = this.onError((reason) => {
        this.log("transport", "error", reason);
        if (primaryTransport && !established) {
          clearTimeout(this.fallbackTimer);
          fallback(reason);
        }
      });
      this.onOpen(() => {
        established = true;
        if (!primaryTransport) {
          if (!this.primaryPassedHealthCheck) {
            this.storeSession(`phx:fallback:${fallbackTransport.name}`, "true");
          }
          return this.log("transport", `established ${fallbackTransport.name} fallback`);
        }
        clearTimeout(this.fallbackTimer);
        this.fallbackTimer = setTimeout(fallback, fallbackThreshold);
        this.ping((rtt) => {
          this.log("transport", "connected to primary after", rtt);
          this.primaryPassedHealthCheck = true;
          clearTimeout(this.fallbackTimer);
        });
      });
      this.transportConnect();
    }
    clearHeartbeats() {
      clearTimeout(this.heartbeatTimer);
      clearTimeout(this.heartbeatTimeoutTimer);
    }
    onConnOpen() {
      if (this.hasLogger()) this.log("transport", `${this.transport.name} connected to ${this.endPointURL()}`);
      this.closeWasClean = false;
      this.disconnecting = false;
      this.establishedConnections++;
      this.flushSendBuffer();
      this.reconnectTimer.reset();
      this.resetHeartbeat();
      this.stateChangeCallbacks.open.forEach(([, callback]) => callback());
    }
    /**
     * @private
     */
    heartbeatTimeout() {
      if (this.pendingHeartbeatRef) {
        this.pendingHeartbeatRef = null;
        if (this.hasLogger()) {
          this.log("transport", "heartbeat timeout. Attempting to re-establish connection");
        }
        this.triggerChanError();
        this.closeWasClean = false;
        this.teardown(() => this.reconnectTimer.scheduleTimeout(), WS_CLOSE_NORMAL, "heartbeat timeout");
      }
    }
    resetHeartbeat() {
      if (this.conn && this.conn.skipHeartbeat) {
        return;
      }
      this.pendingHeartbeatRef = null;
      this.clearHeartbeats();
      this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
    }
    teardown(callback, code, reason) {
      if (!this.conn) {
        return callback && callback();
      }
      let connectClock = this.connectClock;
      this.waitForBufferDone(() => {
        if (connectClock !== this.connectClock) {
          return;
        }
        if (this.conn) {
          if (code) {
            this.conn.close(code, reason || "");
          } else {
            this.conn.close();
          }
        }
        this.waitForSocketClosed(() => {
          if (connectClock !== this.connectClock) {
            return;
          }
          if (this.conn) {
            this.conn.onopen = function() {
            };
            this.conn.onerror = function() {
            };
            this.conn.onmessage = function() {
            };
            this.conn.onclose = function() {
            };
            this.conn = null;
          }
          callback && callback();
        });
      });
    }
    waitForBufferDone(callback, tries = 1) {
      if (tries === 5 || !this.conn || !this.conn.bufferedAmount) {
        callback();
        return;
      }
      setTimeout(() => {
        this.waitForBufferDone(callback, tries + 1);
      }, 150 * tries);
    }
    waitForSocketClosed(callback, tries = 1) {
      if (tries === 5 || !this.conn || this.conn.readyState === SOCKET_STATES.closed) {
        callback();
        return;
      }
      setTimeout(() => {
        this.waitForSocketClosed(callback, tries + 1);
      }, 150 * tries);
    }
    onConnClose(event) {
      let closeCode = event && event.code;
      if (this.hasLogger()) this.log("transport", "close", event);
      this.triggerChanError();
      this.clearHeartbeats();
      if (!this.closeWasClean && closeCode !== 1e3) {
        this.reconnectTimer.scheduleTimeout();
      }
      this.stateChangeCallbacks.close.forEach(([, callback]) => callback(event));
    }
    /**
     * @private
     */
    onConnError(error) {
      if (this.hasLogger()) this.log("transport", error);
      let transportBefore = this.transport;
      let establishedBefore = this.establishedConnections;
      this.stateChangeCallbacks.error.forEach(([, callback]) => {
        callback(error, transportBefore, establishedBefore);
      });
      if (transportBefore === this.transport || establishedBefore > 0) {
        this.triggerChanError();
      }
    }
    /**
     * @private
     */
    triggerChanError() {
      this.channels.forEach((channel) => {
        if (!(channel.isErrored() || channel.isLeaving() || channel.isClosed())) {
          channel.trigger(CHANNEL_EVENTS.error);
        }
      });
    }
    /**
     * @returns {string}
     */
    connectionState() {
      switch (this.conn && this.conn.readyState) {
        case SOCKET_STATES.connecting:
          return "connecting";
        case SOCKET_STATES.open:
          return "open";
        case SOCKET_STATES.closing:
          return "closing";
        default:
          return "closed";
      }
    }
    /**
     * @returns {boolean}
     */
    isConnected() {
      return this.connectionState() === "open";
    }
    /**
     * @private
     *
     * @param {Channel}
     */
    remove(channel) {
      this.off(channel.stateChangeRefs);
      this.channels = this.channels.filter((c) => c !== channel);
    }
    /**
     * Removes `onOpen`, `onClose`, `onError,` and `onMessage` registrations.
     *
     * @param {refs} - list of refs returned by calls to
     *                 `onOpen`, `onClose`, `onError,` and `onMessage`
     */
    off(refs) {
      for (let key in this.stateChangeCallbacks) {
        this.stateChangeCallbacks[key] = this.stateChangeCallbacks[key].filter(([ref]) => {
          return refs.indexOf(ref) === -1;
        });
      }
    }
    /**
     * Initiates a new channel for the given topic
     *
     * @param {string} topic
     * @param {Object} chanParams - Parameters for the channel
     * @returns {Channel}
     */
    channel(topic, chanParams = {}) {
      let chan = new Channel(topic, chanParams, this);
      this.channels.push(chan);
      return chan;
    }
    /**
     * @param {Object} data
     */
    push(data) {
      if (this.hasLogger()) {
        let { topic, event, payload, ref, join_ref } = data;
        this.log("push", `${topic} ${event} (${join_ref}, ${ref})`, payload);
      }
      if (this.isConnected()) {
        this.encode(data, (result) => this.conn.send(result));
      } else {
        this.sendBuffer.push(() => this.encode(data, (result) => this.conn.send(result)));
      }
    }
    /**
     * Return the next message ref, accounting for overflows
     * @returns {string}
     */
    makeRef() {
      let newRef = this.ref + 1;
      if (newRef === this.ref) {
        this.ref = 0;
      } else {
        this.ref = newRef;
      }
      return this.ref.toString();
    }
    sendHeartbeat() {
      if (this.pendingHeartbeatRef && !this.isConnected()) {
        return;
      }
      this.pendingHeartbeatRef = this.makeRef();
      this.push({ topic: "phoenix", event: "heartbeat", payload: {}, ref: this.pendingHeartbeatRef });
      this.heartbeatTimeoutTimer = setTimeout(() => this.heartbeatTimeout(), this.heartbeatIntervalMs);
    }
    flushSendBuffer() {
      if (this.isConnected() && this.sendBuffer.length > 0) {
        this.sendBuffer.forEach((callback) => callback());
        this.sendBuffer = [];
      }
    }
    onConnMessage(rawMessage) {
      this.decode(rawMessage.data, (msg) => {
        let { topic, event, payload, ref, join_ref } = msg;
        if (ref && ref === this.pendingHeartbeatRef) {
          this.clearHeartbeats();
          this.pendingHeartbeatRef = null;
          this.heartbeatTimer = setTimeout(() => this.sendHeartbeat(), this.heartbeatIntervalMs);
        }
        if (this.hasLogger()) this.log("receive", `${payload.status || ""} ${topic} ${event} ${ref && "(" + ref + ")" || ""}`, payload);
        for (let i = 0; i < this.channels.length; i++) {
          const channel = this.channels[i];
          if (!channel.isMember(topic, event, payload, join_ref)) {
            continue;
          }
          channel.trigger(event, payload, ref, join_ref);
        }
        for (let i = 0; i < this.stateChangeCallbacks.message.length; i++) {
          let [, callback] = this.stateChangeCallbacks.message[i];
          callback(msg);
        }
      });
    }
    leaveOpenTopic(topic) {
      let dupChannel = this.channels.find((c) => c.topic === topic && (c.isJoined() || c.isJoining()));
      if (dupChannel) {
        if (this.hasLogger()) this.log("transport", `leaving duplicate topic "${topic}"`);
        dupChannel.leave();
      }
    }
  };

  // ../deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js
  var CONSECUTIVE_RELOADS = "consecutive-reloads";
  var MAX_RELOADS = 10;
  var RELOAD_JITTER_MIN = 5e3;
  var RELOAD_JITTER_MAX = 1e4;
  var FAILSAFE_JITTER = 3e4;
  var PHX_EVENT_CLASSES = [
    "phx-click-loading",
    "phx-change-loading",
    "phx-submit-loading",
    "phx-keydown-loading",
    "phx-keyup-loading",
    "phx-blur-loading",
    "phx-focus-loading",
    "phx-hook-loading"
  ];
  var PHX_DROP_TARGET_ACTIVE_CLASS = "phx-drop-target-active";
  var PHX_COMPONENT = "data-phx-component";
  var PHX_VIEW_REF = "data-phx-view";
  var PHX_LIVE_LINK = "data-phx-link";
  var PHX_TRACK_STATIC = "track-static";
  var PHX_LINK_STATE = "data-phx-link-state";
  var PHX_REF_LOADING = "data-phx-ref-loading";
  var PHX_REF_SRC = "data-phx-ref-src";
  var PHX_REF_LOCK = "data-phx-ref-lock";
  var PHX_PENDING_REFS = "phx-pending-refs";
  var PHX_TRACK_UPLOADS = "track-uploads";
  var PHX_UPLOAD_REF = "data-phx-upload-ref";
  var PHX_PREFLIGHTED_REFS = "data-phx-preflighted-refs";
  var PHX_DONE_REFS = "data-phx-done-refs";
  var PHX_ERROR_REFS = "data-phx-error-refs";
  var PHX_DROP_TARGET = "drop-target";
  var PHX_ACTIVE_ENTRY_REFS = "data-phx-active-refs";
  var PHX_LIVE_FILE_UPDATED = "phx:live-file:updated";
  var PHX_SKIP = "data-phx-skip";
  var PHX_MAGIC_ID = "data-phx-id";
  var PHX_PRUNE = "data-phx-prune";
  var PHX_CONNECTED_CLASS = "phx-connected";
  var PHX_LOADING_CLASS = "phx-loading";
  var PHX_ERROR_CLASS = "phx-error";
  var PHX_CLIENT_ERROR_CLASS = "phx-client-error";
  var PHX_SERVER_ERROR_CLASS = "phx-server-error";
  var PHX_PARENT_ID = "data-phx-parent-id";
  var PHX_MAIN = "data-phx-main";
  var PHX_ROOT_ID = "data-phx-root-id";
  var PHX_VIEWPORT_TOP = "viewport-top";
  var PHX_VIEWPORT_BOTTOM = "viewport-bottom";
  var PHX_VIEWPORT_OVERRUN_TARGET = "viewport-overrun-target";
  var PHX_TRIGGER_ACTION = "trigger-action";
  var PHX_HAS_FOCUSED = "phx-has-focused";
  var FOCUSABLE_INPUTS = [
    "text",
    "textarea",
    "number",
    "email",
    "password",
    "search",
    "tel",
    "url",
    "date",
    "time",
    "datetime-local",
    "color",
    "range"
  ];
  var CHECKABLE_INPUTS = ["checkbox", "radio"];
  var PHX_HAS_SUBMITTED = "phx-has-submitted";
  var PHX_SESSION = "data-phx-session";
  var PHX_VIEW_SELECTOR = `[${PHX_SESSION}]`;
  var PHX_STICKY = "data-phx-sticky";
  var PHX_STATIC = "data-phx-static";
  var PHX_READONLY = "data-phx-readonly";
  var PHX_DISABLED = "data-phx-disabled";
  var PHX_DISABLE_WITH = "disable-with";
  var PHX_DISABLE_WITH_RESTORE = "data-phx-disable-with-restore";
  var PHX_HOOK = "hook";
  var PHX_DEBOUNCE = "debounce";
  var PHX_THROTTLE = "throttle";
  var PHX_UPDATE = "update";
  var PHX_PATCH_FOCUSED = "patch-focused";
  var PHX_STREAM = "stream";
  var PHX_STREAM_REF = "data-phx-stream";
  var PHX_PORTAL = "data-phx-portal";
  var PHX_TELEPORTED_REF = "data-phx-teleported";
  var PHX_TELEPORTED_SRC = "data-phx-teleported-src";
  var PHX_RUNTIME_HOOK = "data-phx-runtime-hook";
  var PHX_LV_PID = "data-phx-pid";
  var PHX_KEY = "key";
  var PHX_PRIVATE = "phxPrivate";
  var PHX_AUTO_RECOVER = "auto-recover";
  var PHX_NO_UNUSED_FIELD = "no-unused-field";
  var PHX_LV_DEBUG = "phx:live-socket:debug";
  var PHX_LV_PROFILE = "phx:live-socket:profiling";
  var PHX_LV_LATENCY_SIM = "phx:live-socket:latency-sim";
  var PHX_LV_HISTORY_POSITION = "phx:nav-history-position";
  var PHX_PROGRESS = "progress";
  var PHX_MOUNTED = "mounted";
  var PHX_RELOAD_STATUS = "__phoenix_reload_status__";
  var LOADER_TIMEOUT = 1;
  var MAX_CHILD_JOIN_ATTEMPTS = 3;
  var BEFORE_UNLOAD_LOADER_TIMEOUT = 200;
  var DISCONNECTED_TIMEOUT = 500;
  var BINDING_PREFIX = "phx-";
  var PUSH_TIMEOUT = 3e4;
  var DEBOUNCE_TRIGGER = "debounce-trigger";
  var THROTTLED = "throttled";
  var DEBOUNCE_PREV_KEY = "debounce-prev-key";
  var DEFAULTS = {
    debounce: 300,
    throttle: 300
  };
  var PHX_PENDING_ATTRS = [PHX_REF_LOADING, PHX_REF_SRC, PHX_REF_LOCK];
  var STATIC = "s";
  var ROOT = "r";
  var COMPONENTS = "c";
  var KEYED = "k";
  var KEYED_COUNT = "kc";
  var KEYED_MOVED = "km";
  var EVENTS = "e";
  var REPLY = "r";
  var TITLE = "t";
  var TEMPLATES = "p";
  var STREAM = "stream";
  var PHX_LV_DIAGNOSTIC_EVENT = "phx:live-view:diagnostic";
  var PHX_LV_DIAGNOSTIC_VERSION = 1;
  var EntryUploader = class {
    constructor(entry, config, liveSocket2) {
      const { chunk_size, chunk_timeout } = config;
      this.liveSocket = liveSocket2;
      this.entry = entry;
      this.offset = 0;
      this.chunkSize = chunk_size;
      this.chunkTimeout = chunk_timeout;
      this.chunkTimer = null;
      this.errored = false;
      this.uploadChannel = liveSocket2.channel(`lvu:${entry.ref}`, {
        token: entry.metadata()
      });
    }
    error(reason) {
      if (this.errored) {
        return;
      }
      this.entry.view.cancelSubmit(this.entry.fileEl.form, {
        reason: "upload-failed",
        inputs: [this.entry.fileEl]
      });
      this.uploadChannel.leave();
      this.errored = true;
      this.chunkTimer != null && clearTimeout(this.chunkTimer);
      if (reason === "writer_error") {
        this.entry.fail(reason, false);
        return;
      }
      this.entry.error(reason);
    }
    upload() {
      this.uploadChannel.onError((reason) => this.error(reason));
      this.uploadChannel.join().receive("ok", (_data) => this.readNextChunk()).receive("error", ({ reason }) => this.error(reason));
    }
    isDone() {
      return this.offset >= this.entry.file.size;
    }
    readNextChunk() {
      const reader = new window.FileReader();
      const blob = this.entry.file.slice(
        this.offset,
        this.chunkSize + this.offset
      );
      const onError = () => {
        this.entry.view.logError(
          "upload.read-failed",
          "Read error: " + (reader.error || "aborted"),
          { entry: this.entry, offset: this.offset }
        );
        this.error("failed");
      };
      reader.onerror = onError;
      reader.onabort = onError;
      reader.onload = (e) => {
        this.offset += /** @type {ArrayBuffer} */
        e.target.result.byteLength;
        this.pushChunk(
          /** @type {ArrayBuffer} */
          e.target.result
        );
      };
      reader.readAsArrayBuffer(blob);
    }
    pushChunk(chunk) {
      if (!this.uploadChannel.isJoined()) {
        return;
      }
      this.uploadChannel.push("chunk", chunk, this.chunkTimeout).receive("ok", () => {
        this.entry.progress(this.offset / this.entry.file.size * 100);
        if (!this.isDone()) {
          this.chunkTimer = setTimeout(
            () => this.readNextChunk(),
            this.liveSocket.getLatencySim() || 0
          );
        }
      }).receive("error", ({ reason }) => this.error(reason)).receive("timeout", () => this.error("timeout"));
    }
  };
  var dispatchDiagnostic = (diagnostic) => {
    window.dispatchEvent(
      new CustomEvent(PHX_LV_DIAGNOSTIC_EVENT, {
        detail: {
          version: PHX_LV_DIAGNOSTIC_VERSION,
          ...diagnostic
        }
      })
    );
  };
  var logError = (code, message, metadata, context) => {
    console.error && console.error(message, metadata);
    dispatchDiagnostic({
      level: "error",
      code,
      message,
      metadata,
      ...context
    });
  };
  var ensureSameOrigin = (href, kind) => {
    let url;
    try {
      url = new URL(href, window.location.href);
    } catch {
      throw new Error(
        `expected ${kind} destination to be a valid URL, got: ${href}`
      );
    }
    if (url.origin !== window.location.origin) {
      throw new Error(
        `cannot ${kind} to "${href}" because its origin does not match the current origin "${window.location.origin}". Use window.location directly for cross-origin navigation.`
      );
    }
  };
  var isCid = (cid) => {
    const type = typeof cid;
    return type === "number" || type === "string" && /^(0|[1-9]\d*)$/.test(cid);
  };
  function detectDuplicateIds(reportError = logError) {
    const ids = /* @__PURE__ */ new Map();
    const elems = document.querySelectorAll("*[id]");
    for (let i = 0, len = elems.length; i < len; i++) {
      const id = elems[i].id;
      const existing = ids.get(id);
      if (existing) {
        reportError(
          "dom.duplicate-id",
          `Multiple IDs detected: ${id}. Ensure unique element ids.`,
          { id, elements: [existing, elems[i]] },
          { attribution: "app" }
        );
      } else {
        ids.set(id, elems[i]);
      }
    }
  }
  function detectInvalidStreamInserts(inserts, reportError = logError) {
    const invalidContainers = /* @__PURE__ */ new Set();
    Object.keys(inserts).forEach((id) => {
      const streamEl = document.getElementById(id);
      if (streamEl && streamEl.parentElement && streamEl.parentElement.getAttribute("phx-update") !== "stream") {
        invalidContainers.add(streamEl.parentElement);
      }
    });
    invalidContainers.forEach((container) => {
      const id = container.id;
      reportError(
        "dom.invalid-stream-container",
        `The stream container with id "${id}" is missing the phx-update="stream" attribute. Ensure it is set for streams to work properly.`,
        { id, container },
        { attribution: "app" }
      );
    });
  }
  var debug = (view, kind, msg, obj) => {
    if (view.liveSocket.isDebugEnabled()) {
      console.log(`${view.id} ${kind}: ${msg} - `, obj);
    }
  };
  var closure2 = (val) => typeof val === "function" ? val : function() {
    return val;
  };
  var clone = (obj) => {
    return JSON.parse(JSON.stringify(obj));
  };
  var deepClone = (obj) => {
    if ("structuredClone" in window) {
      return structuredClone(obj);
    } else {
      return JSON.parse(JSON.stringify(obj));
    }
  };
  var closestPhxBinding = (startEl, binding, borderEl) => {
    let el = startEl;
    do {
      if (el.matches(`[${binding}]`) && !("disabled" in el && el.disabled)) {
        return el;
      }
      el = el.parentElement;
    } while (el !== null && el.nodeType === 1 && !(borderEl && borderEl.isSameNode(el) || el.matches(PHX_VIEW_SELECTOR)));
    return null;
  };
  var isObject = (obj) => {
    return obj !== null && typeof obj === "object" && !(obj instanceof Array);
  };
  var isEqualObj = (obj1, obj2) => JSON.stringify(obj1) === JSON.stringify(obj2);
  var isEmpty = (obj) => {
    for (const x in obj) {
      return false;
    }
    return true;
  };
  var maybe = (el, callback) => el && callback(el);
  var channelUploader = function(entries, onError, resp, liveSocket2) {
    entries.forEach((entry) => {
      const entryUploader = new EntryUploader(entry, resp.config, liveSocket2);
      entryUploader.upload();
    });
  };
  var eventContainsFiles = (e) => {
    if (e.dataTransfer.types) {
      for (let i = 0; i < e.dataTransfer.types.length; i++) {
        if (e.dataTransfer.types[i] === "Files") {
          return true;
        }
      }
    }
    return false;
  };
  var Browser = {
    canPushState() {
      return typeof history.pushState !== "undefined";
    },
    dropLocal(localStorage, namespace, subkey) {
      return localStorage.removeItem(this.localKey(namespace, subkey));
    },
    updateLocal(localStorage, namespace, subkey, initial, func) {
      const current = this.getLocal(localStorage, namespace, subkey);
      const key = this.localKey(namespace, subkey);
      const newVal = current === null ? initial : func(current);
      localStorage.setItem(key, JSON.stringify(newVal));
      return newVal;
    },
    getLocal(localStorage, namespace, subkey) {
      return JSON.parse(localStorage.getItem(this.localKey(namespace, subkey)));
    },
    updateCurrentState(callback) {
      if (!this.canPushState()) {
        return;
      }
      history.replaceState(
        callback(history.state || {}),
        "",
        window.location.href
      );
    },
    pushState(kind, meta, to) {
      if (this.canPushState()) {
        if (to !== window.location.href) {
          if (meta.type == "redirect" && meta.scroll) {
            const currentState = history.state || {};
            currentState.scroll = meta.scroll;
            history.replaceState(currentState, "", window.location.href);
          }
          delete meta.scroll;
          history[kind + "State"](meta, "", to || null);
          window.requestAnimationFrame(() => {
            const hashEl = this.getHashTargetEl(window.location.hash);
            if (hashEl) {
              hashEl.scrollIntoView();
            } else if (meta.type === "redirect") {
              window.scroll(0, 0);
            }
          });
        }
      } else if (to) {
        this.redirect(to);
      }
    },
    setCookie(name, value, maxAgeSeconds) {
      const expires = typeof maxAgeSeconds === "number" ? ` max-age=${maxAgeSeconds};` : "";
      document.cookie = `${name}=${value};${expires} path=/`;
    },
    deleteCookie(name) {
      document.cookie = `${name}=; max-age=-1; path=/`;
    },
    redirect(toURL, flash = null, navigate = (url) => {
      window.location.href = url;
    }) {
      if (flash) {
        this.setCookie("__phoenix_flash__", flash, 60);
      }
      navigate(toURL);
    },
    localKey(namespace, subkey) {
      return `${namespace}-${subkey}`;
    },
    getHashTargetEl(maybeHash) {
      const hash = maybeHash.toString().substring(1);
      if (hash === "") {
        return;
      }
      return document.getElementById(hash) || document.querySelector(`a[name="${hash}"]`);
    }
  };
  var browser_default = Browser;
  var DOM = {
    byId(id) {
      return document.getElementById(id) || logError(
        "dom.element-not-found",
        `no id found for ${id}`,
        { id },
        { attribution: "internal" }
      );
    },
    elementFromTarget(target) {
      if (!(target instanceof Node)) {
        return null;
      }
      if (target.nodeType === Node.ELEMENT_NODE) {
        return target;
      } else {
        return target.parentElement;
      }
    },
    removeClass(el, className) {
      el.classList.remove(className);
      if (el.classList.length === 0) {
        el.removeAttribute("class");
      }
    },
    all(node, query, callback) {
      if (!node) {
        return [];
      }
      const array = Array.from(node.querySelectorAll(query));
      if (callback) {
        array.forEach(callback);
      }
      return array;
    },
    isUploadInput(el) {
      return el.type === "file" && el.getAttribute(PHX_UPLOAD_REF) !== null;
    },
    isAutoUpload(inputEl) {
      return inputEl.hasAttribute("data-phx-auto-upload");
    },
    findUploadInputs(node) {
      const formId = node.id;
      const inputsOutsideForm = this.all(
        document,
        `input[type="file"][${PHX_UPLOAD_REF}][form="${formId}"]`
      );
      return this.all(node, `input[type="file"][${PHX_UPLOAD_REF}]`).concat(
        inputsOutsideForm
      );
    },
    findComponent(viewId, cid, doc2 = document) {
      return doc2.querySelector(
        `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
      );
    },
    getComponent(viewId, cid, doc2 = document) {
      const el = this.findComponent(viewId, cid, doc2);
      if (!el) {
        throw new Error(
          `no component found matching viewId ${viewId} and cid ${cid}`
        );
      }
      return el;
    },
    isPhxDestroyed(node) {
      return node.id && DOM.private(node, "destroyed") ? true : false;
    },
    wantsNewTab(e, el = e.target) {
      const wantsNewTab = e.ctrlKey || e.shiftKey || e.metaKey || e.button && e.button === 1;
      const isDownload = el instanceof HTMLAnchorElement && el.hasAttribute("download");
      const target = e.submitter && e.submitter.hasAttribute("formtarget") ? e.submitter.getAttribute("formtarget") : el.getAttribute("target");
      const isTargetBlank = target !== null && target.toLowerCase() === "_blank";
      const isTargetNamedTab = target !== null && target !== "" && !target.startsWith("_");
      return wantsNewTab || isTargetBlank || isDownload || isTargetNamedTab;
    },
    isUnloadableFormSubmit(e) {
      const isDialogSubmit = e.target && e.target.getAttribute("method") === "dialog" || e.submitter && e.submitter.getAttribute("formmethod") === "dialog";
      if (isDialogSubmit) {
        return false;
      } else {
        return !e.defaultPrevented && !this.wantsNewTab(e);
      }
    },
    isNewPageClick(e, currentLocation) {
      const href = e.target instanceof HTMLAnchorElement ? e.target.getAttribute("href") : null;
      let url;
      if (e.defaultPrevented || href === null || this.wantsNewTab(e)) {
        return false;
      }
      if (href.startsWith("mailto:") || href.startsWith("tel:")) {
        return false;
      }
      if (e.target.isContentEditable) {
        return false;
      }
      try {
        url = new URL(href);
      } catch {
        try {
          url = new URL(href, currentLocation);
        } catch {
          return true;
        }
      }
      if (url.host === currentLocation.host && url.protocol === currentLocation.protocol) {
        if (url.pathname === currentLocation.pathname && url.search === currentLocation.search) {
          return url.hash === "" && !url.href.endsWith("#");
        }
      }
      return url.protocol.startsWith("http");
    },
    markPhxChildDestroyed(el) {
      if (this.isPhxChild(el)) {
        el.setAttribute(PHX_SESSION, "");
      }
      this.putPrivate(el, "destroyed", true);
    },
    findPhxChildrenInFragment(html, parentId) {
      const template = document.createElement("template");
      template.innerHTML = html;
      return this.findPhxChildren(template.content, parentId);
    },
    isIgnored(el, phxUpdate) {
      return (el.getAttribute(phxUpdate) || el.getAttribute("data-phx-update")) === "ignore";
    },
    isPhxUpdate(el, phxUpdate, updateTypes) {
      return el.getAttribute && updateTypes.indexOf(el.getAttribute(phxUpdate)) >= 0;
    },
    findPhxSticky(el) {
      return this.all(el, `[${PHX_STICKY}]`);
    },
    findPhxChildren(el, parentId) {
      return this.all(el, `${PHX_VIEW_SELECTOR}[${PHX_PARENT_ID}="${parentId}"]`);
    },
    findExistingParentCIDs(viewId, cids) {
      const parentCids = /* @__PURE__ */ new Set();
      const childrenCids = /* @__PURE__ */ new Set();
      cids.forEach((cid) => {
        this.all(
          document,
          `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
        ).forEach((parent) => {
          parentCids.add(cid);
          this.all(parent, `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}]`).map((el) => parseInt(el.getAttribute(PHX_COMPONENT))).forEach((childCID) => childrenCids.add(childCID));
        });
      });
      childrenCids.forEach((childCid) => parentCids.delete(childCid));
      return parentCids;
    },
    private(el, key) {
      return el[PHX_PRIVATE] && el[PHX_PRIVATE][key];
    },
    deletePrivate(el, key) {
      el[PHX_PRIVATE] && delete el[PHX_PRIVATE][key];
    },
    putPrivate(el, key, value) {
      if (!el[PHX_PRIVATE]) {
        el[PHX_PRIVATE] = {};
      }
      el[PHX_PRIVATE][key] = value;
    },
    updatePrivate(el, key, defaultVal, updateFunc) {
      const existing = this.private(el, key);
      if (existing === void 0) {
        this.putPrivate(el, key, updateFunc(defaultVal));
      } else {
        this.putPrivate(el, key, updateFunc(existing));
      }
    },
    syncPendingAttrs(fromEl, toEl) {
      if (!fromEl.hasAttribute(PHX_REF_SRC)) {
        return;
      }
      PHX_EVENT_CLASSES.forEach((className) => {
        fromEl.classList.contains(className) && toEl.classList.add(className);
      });
      PHX_PENDING_ATTRS.filter((attr) => fromEl.hasAttribute(attr)).forEach(
        (attr) => {
          toEl.setAttribute(attr, fromEl.getAttribute(attr));
        }
      );
    },
    copyPrivates(target, source) {
      if (source[PHX_PRIVATE]) {
        target[PHX_PRIVATE] = source[PHX_PRIVATE];
      }
    },
    putTitle(str) {
      const titleEl = document.querySelector("title");
      if (titleEl) {
        const { prefix, suffix, default: defaultTitle } = titleEl.dataset;
        const isEmpty2 = typeof str !== "string" || str.trim() === "";
        if (isEmpty2 && typeof defaultTitle !== "string") {
          return;
        }
        const inner = isEmpty2 ? defaultTitle : str;
        document.title = `${prefix || ""}${inner || ""}${suffix || ""}`;
      } else {
        document.title = str;
      }
    },
    debounce(el, event, phxDebounce, defaultDebounce, phxThrottle, defaultThrottle, asyncFilter, callback) {
      let debounce = el.getAttribute(phxDebounce);
      let throttle = el.getAttribute(phxThrottle);
      if (debounce === "") {
        debounce = defaultDebounce;
      }
      if (throttle === "") {
        throttle = defaultThrottle;
      }
      const value = debounce || throttle;
      switch (value) {
        case null:
          return callback();
        case "blur":
          this.incCycle(el, "debounce-blur-cycle", () => {
            if (asyncFilter()) {
              callback();
            }
          });
          if (this.once(el, "debounce-blur")) {
            el.addEventListener(
              "blur",
              () => this.triggerCycle(el, "debounce-blur-cycle")
            );
          }
          return;
        default:
          const timeout = parseInt(value);
          const trigger = () => throttle ? this.deletePrivate(el, THROTTLED) : callback();
          const currentCycle = this.incCycle(el, DEBOUNCE_TRIGGER, trigger);
          if (isNaN(timeout)) {
            return logError(
              "dom.invalid-debounce",
              `invalid throttle/debounce value: ${value}`,
              { el, value },
              { attribution: "app" }
            );
          }
          if (throttle) {
            let newKeyDown = false;
            if (event.type === "keydown") {
              const prevKey = this.private(el, DEBOUNCE_PREV_KEY);
              this.putPrivate(el, DEBOUNCE_PREV_KEY, event.key);
              newKeyDown = prevKey !== event.key;
            }
            if (!newKeyDown && this.private(el, THROTTLED)) {
              return false;
            } else {
              callback();
              const t = setTimeout(() => {
                if (asyncFilter()) {
                  this.triggerCycle(el, DEBOUNCE_TRIGGER);
                }
              }, timeout);
              this.putPrivate(el, THROTTLED, t);
            }
          } else {
            setTimeout(() => {
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER, currentCycle);
              }
            }, timeout);
          }
          const form = el.form;
          if (form && this.once(form, "bind-debounce")) {
            form.addEventListener("submit", () => {
              Array.from(new FormData(form).entries(), ([name]) => {
                const namedItem = form.elements.namedItem(name);
                const input = namedItem instanceof RadioNodeList ? namedItem[0] : namedItem;
                if (input) {
                  this.incCycle(input, DEBOUNCE_TRIGGER);
                  this.deletePrivate(input, THROTTLED);
                }
              });
            });
          }
          if (this.once(el, "bind-debounce")) {
            el.addEventListener("blur", () => {
              clearTimeout(this.private(el, THROTTLED));
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER);
              }
            });
          }
      }
    },
    triggerCycle(el, key, currentCycle) {
      const [cycle, trigger] = this.private(el, key);
      if (!currentCycle) {
        currentCycle = cycle;
      }
      if (currentCycle === cycle) {
        this.incCycle(el, key);
        trigger();
      }
    },
    once(el, key) {
      if (this.private(el, key) === true) {
        return false;
      }
      this.putPrivate(el, key, true);
      return true;
    },
    incCycle(el, key, trigger = function() {
    }) {
      let [currentCycle] = this.private(el, key) || [0, trigger];
      currentCycle++;
      this.putPrivate(el, key, [currentCycle, trigger]);
      return currentCycle;
    },
    // maintains or adds privately used hook information
    // fromEl and toEl can be the same element in the case of a newly added node
    // fromEl and toEl can be any HTML node type, so we need to check if it's an element node
    maintainPrivateHooks(fromEl, toEl, phxViewportTop, phxViewportBottom) {
      if (fromEl.hasAttribute && fromEl.hasAttribute("data-phx-hook") && !toEl.hasAttribute("data-phx-hook")) {
        toEl.setAttribute("data-phx-hook", fromEl.getAttribute("data-phx-hook"));
      }
      if (toEl.hasAttribute && (toEl.hasAttribute(phxViewportTop) || toEl.hasAttribute(phxViewportBottom))) {
        toEl.setAttribute("data-phx-hook", "Phoenix.InfiniteScroll");
      }
    },
    putCustomElHook(el, hook) {
      if (el.isConnected) {
        el.setAttribute("data-phx-hook", "");
      } else {
        logError(
          "hook.non-connected-element",
          `
        hook attached to non-connected DOM element
        ensure you are calling createHook within your connectedCallback. ${el.outerHTML}
      `,
          { el },
          { attribution: "app" }
        );
      }
      this.putPrivate(el, "custom-el-hook", hook);
    },
    getCustomElHook(el) {
      return this.private(el, "custom-el-hook");
    },
    isUsedInput(el) {
      return el.nodeType === Node.ELEMENT_NODE && (this.private(el, PHX_HAS_FOCUSED) || this.private(el, PHX_HAS_SUBMITTED));
    },
    resetForm(form) {
      Array.from(form.elements).forEach((input) => {
        this.deletePrivate(input, PHX_HAS_FOCUSED);
        this.deletePrivate(input, PHX_HAS_SUBMITTED);
      });
    },
    isPhxChild(node) {
      return node.getAttribute && node.getAttribute(PHX_PARENT_ID);
    },
    isPhxSticky(node) {
      return node.getAttribute && node.getAttribute(PHX_STICKY) !== null;
    },
    isChildOfAny(el, parents) {
      return !!parents.find((parent) => parent.contains(el));
    },
    firstPhxChild(el) {
      return this.isPhxChild(el) ? el : this.all(el, `[${PHX_PARENT_ID}]`)[0];
    },
    isPortalTemplate(el) {
      return el.tagName === "TEMPLATE" && el.hasAttribute(PHX_PORTAL);
    },
    closestViewEl(el) {
      const portalOrViewEl = el.closest(
        `[${PHX_TELEPORTED_REF}],${PHX_VIEW_SELECTOR}`
      );
      if (!portalOrViewEl) {
        return null;
      }
      if (portalOrViewEl.hasAttribute(PHX_TELEPORTED_REF)) {
        return this.byId(portalOrViewEl.getAttribute(PHX_TELEPORTED_REF));
      } else if (portalOrViewEl.hasAttribute(PHX_SESSION)) {
        return portalOrViewEl;
      }
      return null;
    },
    dispatchEvent(target, name, opts = {}) {
      let defaultBubble = true;
      const isUploadTarget = target.nodeName === "INPUT" && target.type === "file";
      if (isUploadTarget && name === "click") {
        defaultBubble = false;
      }
      const bubbles = opts.bubbles === void 0 ? defaultBubble : !!opts.bubbles;
      const eventOpts = {
        bubbles,
        cancelable: true,
        detail: opts.detail || {}
      };
      const event = name === "click" ? new MouseEvent("click", eventOpts) : new CustomEvent(name, eventOpts);
      return target.dispatchEvent(event);
    },
    cloneNode(node, html) {
      if (typeof html === "undefined") {
        return node.cloneNode(true);
      } else {
        const cloned = node.cloneNode(false);
        cloned.innerHTML = html;
        return cloned;
      }
    },
    // merge attributes from source to target
    // if an element is ignored, we only merge data attributes
    // including removing data attributes that are no longer in the source
    mergeAttrs(target, source, opts = {}) {
      const exclude = new Set(opts.exclude || []);
      const isIgnored = opts.isIgnored;
      const sourceAttrs = source.attributes;
      for (let i = sourceAttrs.length - 1; i >= 0; i--) {
        const name = sourceAttrs[i].name;
        if (!exclude.has(name)) {
          const sourceValue = source.getAttribute(name);
          if (target.getAttribute(name) !== sourceValue && (!isIgnored || isIgnored && name.startsWith("data-"))) {
            target.setAttribute(name, sourceValue);
          }
        } else {
          if (name === "value") {
            const sourceValue = source.value ?? source.getAttribute(name);
            if (target.value === sourceValue) {
              target.setAttribute("value", source.getAttribute(name));
            }
          }
        }
      }
      const targetAttrs = target.attributes;
      for (let i = targetAttrs.length - 1; i >= 0; i--) {
        const name = targetAttrs[i].name;
        if (isIgnored) {
          if (name.startsWith("data-") && !source.hasAttribute(name) && !PHX_PENDING_ATTRS.includes(name)) {
            target.removeAttribute(name);
          }
        } else {
          if (!source.hasAttribute(name)) {
            target.removeAttribute(name);
          }
        }
      }
    },
    mergeFocusedInput(target, source) {
      if (!(target instanceof HTMLSelectElement)) {
        DOM.mergeAttrs(target, source, { exclude: ["value"] });
      }
      if (source.readOnly) {
        target.setAttribute("readonly", true);
      } else {
        target.removeAttribute("readonly");
      }
    },
    hasSelectionRange(el) {
      return el.setSelectionRange && ["text", "textarea", "search", "url", "tel", "password"].includes(el.type);
    },
    restoreFocus(focused, selectionStart, selectionEnd) {
      if (focused instanceof HTMLSelectElement) {
        focused.focus();
      }
      if (!DOM.isTextualInput(focused)) {
        return;
      }
      const wasFocused = focused.matches(":focus");
      if (!wasFocused) {
        focused.focus();
      }
      if (this.hasSelectionRange(focused)) {
        focused.setSelectionRange(selectionStart, selectionEnd);
      }
    },
    /**
     * Returns true if the element is an input that can be focused and edited by the user,
     * so we can skip patching it if it has focus.
     */
    isEditableInput(el) {
      return this.isFormAssociated(el) && !(el instanceof HTMLButtonElement) && !(el instanceof HTMLInputElement && el.type === "button");
    },
    isFormAssociated(el) {
      if (!(el instanceof HTMLElement))
        return false;
      if (el.localName) {
        const customEl = customElements.get(el.localName);
        if (customEl) {
          return customEl.formAssociated === true;
        }
      }
      return el instanceof HTMLInputElement || el instanceof HTMLSelectElement || el instanceof HTMLTextAreaElement || el instanceof HTMLButtonElement;
    },
    syncAttrsToProps(el) {
      if (el instanceof HTMLInputElement && CHECKABLE_INPUTS.indexOf(el.type.toLocaleLowerCase()) >= 0) {
        el.checked = el.getAttribute("checked") !== null;
      }
    },
    isTextualInput(el) {
      return FOCUSABLE_INPUTS.indexOf(el.type) >= 0;
    },
    isNowTriggerFormExternal(el, phxTriggerExternal) {
      return el.getAttribute && el.getAttribute(phxTriggerExternal) !== null && document.body.contains(el);
    },
    cleanChildNodes(container, phxUpdate, reportError = logError) {
      if (DOM.isPhxUpdate(container, phxUpdate, ["append", "prepend", PHX_STREAM])) {
        const toRemove = [];
        container.childNodes.forEach((childNode) => {
          if (!("id" in childNode) || !childNode.id) {
            const isEmptyTextNode = childNode.nodeType === Node.TEXT_NODE && childNode.nodeValue && childNode.nodeValue.trim() === "";
            if (!isEmptyTextNode && childNode.nodeType !== Node.COMMENT_NODE) {
              reportError(
                "dom.invalid-phx-update-child",
                `only HTML element tags with an id are allowed inside containers with phx-update.

removing illegal node: "${("outerHTML" in childNode && childNode.outerHTML || childNode.nodeValue || "").trim()}"

`,
                { container, childNode, phxUpdate },
                { attribution: "app" }
              );
            }
            toRemove.push(childNode);
          }
        });
        toRemove.forEach((childNode) => childNode.remove());
      }
    },
    replaceRootContainer(container, tagName, attrs) {
      const retainedAttrs = /* @__PURE__ */ new Set([
        "id",
        PHX_SESSION,
        PHX_STATIC,
        PHX_MAIN,
        PHX_ROOT_ID
      ]);
      if (container.tagName.toLowerCase() === tagName.toLowerCase()) {
        Array.from(container.attributes).filter((attr) => !retainedAttrs.has(attr.name.toLowerCase())).forEach((attr) => container.removeAttribute(attr.name));
        Object.keys(attrs).filter((name) => !retainedAttrs.has(name.toLowerCase())).forEach((attr) => container.setAttribute(attr, attrs[attr]));
        return container;
      } else {
        const newContainer = document.createElement(tagName);
        Object.keys(attrs).forEach(
          (attr) => newContainer.setAttribute(attr, attrs[attr])
        );
        retainedAttrs.forEach((attr) => {
          const value = container.getAttribute(attr);
          if (value !== null) {
            newContainer.setAttribute(attr, value);
          }
        });
        newContainer.innerHTML = container.innerHTML;
        container.replaceWith(newContainer);
        return newContainer;
      }
    },
    getSticky(el, name, defaultVal) {
      const op = (DOM.private(el, "sticky") || []).find(
        ([existingName]) => name === existingName
      );
      if (op) {
        const [_name, _op, stashedResult] = op;
        return stashedResult;
      } else {
        return typeof defaultVal === "function" ? defaultVal() : defaultVal;
      }
    },
    putSticky(el, name, op) {
      const stashedResult = op(el);
      this.updatePrivate(el, "sticky", [], (ops) => {
        const existingIndex = ops.findIndex(
          ([existingName]) => name === existingName
        );
        if (existingIndex >= 0) {
          ops[existingIndex] = [name, op, stashedResult];
        } else {
          ops.push([name, op, stashedResult]);
        }
        return ops;
      });
    },
    applyStickyOperations(el) {
      const ops = DOM.private(el, "sticky");
      if (!ops) {
        return;
      }
      ops.forEach(([name, op, _stashed]) => this.putSticky(el, name, op));
    },
    isLocked(el) {
      return el.hasAttribute && el.hasAttribute(PHX_REF_LOCK);
    },
    attributeIgnored(attribute, ignoredAttributes) {
      return ignoredAttributes.some(
        (toIgnore) => attribute.name == toIgnore || toIgnore === "*" || toIgnore.includes("*") && attribute.name.match(toIgnore) != null
      );
    }
  };
  var dom_default = DOM;
  var UploadEntry = class {
    static isActive(fileEl, file) {
      const ref = file._phxRef;
      const isNew = ref === void 0;
      const activeRefs = fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
      const isActive = !isNew && activeRefs.indexOf(ref) >= 0;
      return file.size > 0 && (isNew || isActive);
    }
    static isPreflighted(fileEl, file) {
      const preflightedRefs = fileEl.getAttribute(PHX_PREFLIGHTED_REFS).split(",");
      const isPreflighted = preflightedRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
      return isPreflighted && this.isActive(fileEl, file);
    }
    static isPreflightInProgress(file) {
      return file._preflightInProgress === true;
    }
    static markPreflightInProgress(file) {
      file._preflightInProgress = true;
    }
    constructor(fileEl, file, view, autoUpload) {
      this.ref = LiveUploader.genFileRef(file);
      this.fileEl = fileEl;
      this.file = file;
      this.view = view;
      this.meta = null;
      this._isCancelled = false;
      this._isDone = false;
      this._isErrored = false;
      this._progress = 0;
      this._lastProgressSent = -1;
      this._onCancel = function() {
      };
      this._onDone = function() {
      };
      this._onElUpdated = this.onElUpdated.bind(this);
      this.fileEl.addEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      this.autoUpload = autoUpload;
    }
    metadata() {
      return this.meta;
    }
    progress(progress) {
      this._progress = Math.floor(progress);
      if (this._progress > this._lastProgressSent) {
        if (this._progress >= 100) {
          this._progress = 100;
          this._lastProgressSent = 100;
          this._isDone = true;
          this.view.pushFileProgress(this.fileEl, this.ref, 100, () => {
            LiveUploader.untrackFile(this.fileEl, this.file);
            this._onDone();
          });
        } else {
          this._lastProgressSent = this._progress;
          this.view.pushFileProgress(this.fileEl, this.ref, this._progress);
        }
      }
    }
    isCancelled() {
      return this._isCancelled;
    }
    cancel() {
      this.file._preflightInProgress = false;
      this._isCancelled = true;
      this._isDone = true;
      try {
        this._onCancel();
      } finally {
        this._onDone();
      }
    }
    isDone() {
      return this._isDone;
    }
    error(reason = "failed") {
      this.fail(reason, true);
    }
    isErrored() {
      return this._isErrored;
    }
    isAutoUpload() {
      return this.autoUpload;
    }
    onCancel(callback) {
      if (this.isCancelled()) {
        callback();
      } else {
        this._onCancel = callback;
      }
    }
    //private
    // notifyServer is false when the server already recorded the failure,
    // for example for upload writer errors
    fail(reason, notifyServer) {
      if (this._isErrored) {
        return;
      }
      this._isErrored = true;
      this._isDone = true;
      this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      try {
        if (notifyServer) {
          this.view.pushFileProgress(this.fileEl, this.ref, { error: reason });
        }
        if (!this.isAutoUpload()) {
          LiveUploader.clearFiles(this.fileEl);
        }
      } finally {
        this._onDone();
      }
    }
    onDone(callback) {
      this._onDone = () => {
        this._onDone = function() {
        };
        this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
        callback();
      };
    }
    onElUpdated() {
      const activeRefs = this.fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
      if (activeRefs.indexOf(this.ref) === -1) {
        LiveUploader.untrackFile(this.fileEl, this.file);
        this.cancel();
      }
    }
    toPreflightPayload() {
      return {
        last_modified: this.file.lastModified,
        name: this.file.name,
        relative_path: this.file.webkitRelativePath,
        size: this.file.size,
        type: this.file.type,
        ref: this.ref,
        meta: typeof this.file.meta === "function" ? this.file.meta() : void 0
      };
    }
    uploader(uploaders) {
      if (this.meta.uploader) {
        const callback = uploaders[this.meta.uploader] || this.view.logError(
          "upload.missing-uploader",
          `no uploader configured for ${this.meta.uploader}`,
          { uploader: this.meta.uploader, uploaders }
        );
        return { name: this.meta.uploader, callback };
      } else {
        return { name: "channel", callback: channelUploader };
      }
    }
    zipPostFlight(resp) {
      this.meta = resp.entries[this.ref];
      if (!this.meta) {
        this.view.logError(
          "upload.missing-preflight-response",
          `no preflight upload response returned with ref ${this.ref}`,
          {
            ref: this.ref,
            input: this.fileEl,
            response: resp
          },
          { attribution: "internal" }
        );
      }
    }
  };
  var liveUploaderFileRef = 0;
  var LiveUploader = class _LiveUploader {
    static genFileRef(file) {
      const ref = file._phxRef;
      if (ref !== void 0) {
        return ref;
      } else {
        file._phxRef = (liveUploaderFileRef++).toString();
        return file._phxRef;
      }
    }
    static getEntryDataURL(inputEl, ref) {
      const file = this.activeFiles(inputEl).find(
        (file2) => this.genFileRef(file2) === ref
      );
      if (!file)
        return null;
      return URL.createObjectURL(file);
    }
    static hasUploadsInProgress(formEl) {
      let active = 0;
      dom_default.findUploadInputs(formEl).forEach((input) => {
        if (input.getAttribute(PHX_PREFLIGHTED_REFS) !== input.getAttribute(PHX_DONE_REFS)) {
          active++;
        }
      });
      return active > 0;
    }
    static inputsWithUploadErrors(formEl) {
      return dom_default.findUploadInputs(formEl).filter(
        (input) => (input.getAttribute(PHX_ERROR_REFS) || "") !== ""
      );
    }
    static serializeUploads(inputEl) {
      const files = this.activeFiles(inputEl);
      const fileData = {};
      files.forEach((file) => {
        const entry = { path: inputEl.name };
        const uploadRef = inputEl.getAttribute(PHX_UPLOAD_REF);
        fileData[uploadRef] = fileData[uploadRef] || [];
        entry.ref = this.genFileRef(file);
        entry.last_modified = file.lastModified;
        entry.name = file.name || entry.ref;
        entry.relative_path = file.webkitRelativePath;
        entry.type = file.type;
        entry.size = file.size;
        if (typeof file.meta === "function") {
          entry.meta = file.meta();
        }
        fileData[uploadRef].push(entry);
      });
      return fileData;
    }
    static clearFiles(inputEl) {
      inputEl.value = null;
      inputEl.removeAttribute(PHX_UPLOAD_REF);
      dom_default.putPrivate(inputEl, "files", []);
    }
    static untrackFile(inputEl, file) {
      dom_default.putPrivate(
        inputEl,
        "files",
        dom_default.private(inputEl, "files").filter((f) => !Object.is(f, file))
      );
    }
    /**
     * @param {HTMLInputElement} inputEl
     * @param {Array<File|Blob>} files
     * @param {DataTransfer} [dataTransfer]
     */
    static trackFiles(inputEl, files, dataTransfer) {
      if (inputEl.getAttribute("multiple") !== null) {
        const newFiles = files.filter(
          (file) => !this.activeFiles(inputEl).find((f) => Object.is(f, file))
        );
        dom_default.updatePrivate(
          inputEl,
          "files",
          [],
          (existing) => existing.concat(newFiles)
        );
        inputEl.value = "";
      } else {
        if (dataTransfer && dataTransfer.files.length > 0) {
          inputEl.files = dataTransfer.files;
        }
        dom_default.putPrivate(inputEl, "files", files);
      }
    }
    static activeFileInputs(formEl) {
      return dom_default.findUploadInputs(formEl).filter(
        (el) => el.files && this.activeFiles(el).length > 0
      );
    }
    static activeFiles(input) {
      return (dom_default.private(input, "files") || []).filter(
        (f) => UploadEntry.isActive(input, f)
      );
    }
    static inputsAwaitingPreflight(formEl) {
      return dom_default.findUploadInputs(formEl).filter(
        (input) => this.filesAwaitingPreflight(input).length > 0
      );
    }
    static filesAwaitingPreflight(input) {
      return this.activeFiles(input).filter(
        (f) => !UploadEntry.isPreflighted(input, f) && !UploadEntry.isPreflightInProgress(f)
      );
    }
    static markPreflightInProgress(entries) {
      entries.forEach((entry) => UploadEntry.markPreflightInProgress(entry.file));
    }
    constructor(inputEl, view, onComplete) {
      this.autoUpload = dom_default.isAutoUpload(inputEl);
      this.view = view;
      this.onComplete = onComplete;
      this._entries = Array.from(
        _LiveUploader.filesAwaitingPreflight(inputEl) || []
      ).map((file) => new UploadEntry(inputEl, file, view, this.autoUpload));
      _LiveUploader.markPreflightInProgress(this._entries);
      this.numEntriesInProgress = this._entries.length;
    }
    isAutoUpload() {
      return this.autoUpload;
    }
    entries() {
      return this._entries;
    }
    cancel() {
      this._entries.filter((entry) => !entry.isDone()).forEach((entry) => entry.cancel());
    }
    initAdapterUpload(resp, onError, liveSocket2) {
      this._entries = this._entries.map((entry) => {
        if (entry.isCancelled()) {
          this.numEntriesInProgress--;
          if (this.numEntriesInProgress === 0) {
            this.onComplete();
          }
        } else {
          entry.zipPostFlight(resp);
          entry.onDone(() => {
            this.numEntriesInProgress--;
            if (this.numEntriesInProgress === 0) {
              this.onComplete();
            }
          });
        }
        return entry;
      });
      const groupedEntries = this._entries.reduce((acc, entry) => {
        if (!entry.meta) {
          return acc;
        }
        const { name, callback } = entry.uploader(liveSocket2.uploaders);
        acc[name] = acc[name] || { callback, entries: [] };
        acc[name].entries.push(entry);
        return acc;
      }, {});
      for (const name in groupedEntries) {
        const { callback, entries } = groupedEntries[name];
        callback(entries, onError, resp, liveSocket2);
      }
    }
  };
  var ARIA = {
    anyOf(instance, classes) {
      return classes.some((name) => instance instanceof name);
    },
    isFocusable(el, interactiveOnly = false) {
      return el instanceof HTMLAnchorElement && el.rel !== "ignore" || el instanceof HTMLAreaElement && el.href !== void 0 || !("disabled" in el && el.disabled) && this.anyOf(el, [
        HTMLInputElement,
        HTMLSelectElement,
        HTMLTextAreaElement,
        HTMLButtonElement
      ]) || el instanceof HTMLIFrameElement || el instanceof HTMLElement && el.tabIndex >= 0 && el.getAttribute("aria-hidden") !== "true" || !interactiveOnly && el.getAttribute("tabindex") !== null && el.getAttribute("aria-hidden") !== "true";
    },
    attemptFocus(el, interactiveOnly = false) {
      if (this.isFocusable(el, interactiveOnly)) {
        try {
          el.focus();
        } catch {
        }
      }
      return !!document.activeElement && document.activeElement.isSameNode(el);
    },
    focusFirstInteractive(el) {
      let child = el.firstElementChild;
      while (child) {
        if (this.attemptFocus(child, true) || this.focusFirstInteractive(child)) {
          return true;
        }
        child = child.nextElementSibling;
      }
      return false;
    },
    focusFirst(el) {
      let child = el.firstElementChild;
      while (child) {
        if (this.attemptFocus(child) || this.focusFirst(child)) {
          return true;
        }
        child = child.nextElementSibling;
      }
      return false;
    },
    focusLast(el) {
      let child = el.lastElementChild;
      while (child) {
        if (this.attemptFocus(child) || this.focusLast(child)) {
          return true;
        }
        child = child.previousElementSibling;
      }
      return false;
    }
  };
  var aria_default = ARIA;
  var findScrollContainer = (el) => {
    if (["HTML", "BODY"].indexOf(el.nodeName.toUpperCase()) >= 0)
      return null;
    if (["scroll", "auto"].indexOf(getComputedStyle(el).overflowY) >= 0)
      return el;
    return findScrollContainer(el.parentElement);
  };
  var scrollTop = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.scrollTop;
    } else {
      return document.documentElement.scrollTop || document.body.scrollTop;
    }
  };
  var bottom = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.getBoundingClientRect().bottom;
    } else {
      return window.innerHeight || document.documentElement.clientHeight;
    }
  };
  var top = (scrollContainer) => {
    if (scrollContainer) {
      return scrollContainer.getBoundingClientRect().top;
    } else {
      return 0;
    }
  };
  var isAtViewportTop = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.top) >= top(scrollContainer) && Math.floor(rect.top) <= bottom(scrollContainer);
  };
  var isAtViewportBottom = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.bottom) >= top(scrollContainer) && Math.floor(rect.bottom) <= bottom(scrollContainer);
  };
  var isWithinViewport = (el, scrollContainer) => {
    const rect = el.getBoundingClientRect();
    return Math.ceil(rect.top) >= top(scrollContainer) && Math.floor(rect.top) <= bottom(scrollContainer);
  };
  var InfiniteScroll = {
    mounted() {
      this.scrollContainer = findScrollContainer(this.el);
      let scrollBefore = scrollTop(this.scrollContainer);
      let topOverran = false;
      const throttleInterval = 500;
      let pendingOp = null;
      const onTopOverrun = this.throttle(
        throttleInterval,
        (topEvent, firstChild) => {
          pendingOp = () => true;
          this.liveSocket.js().push(this.el, topEvent, {
            value: { id: firstChild.id, _overran: true },
            callback: () => {
              pendingOp = null;
            }
          });
        }
      );
      const onFirstChildAtTop = this.throttle(
        throttleInterval,
        (topEvent, firstChild) => {
          pendingOp = () => firstChild.scrollIntoView({ block: "start" });
          this.liveSocket.js().push(this.el, topEvent, {
            value: { id: firstChild.id },
            callback: () => {
              pendingOp = null;
              window.requestAnimationFrame(() => {
                if (!isWithinViewport(firstChild, this.scrollContainer)) {
                  firstChild.scrollIntoView({ block: "start" });
                }
              });
            }
          });
        }
      );
      const onLastChildAtBottom = this.throttle(
        throttleInterval,
        (bottomEvent, lastChild) => {
          pendingOp = () => lastChild.scrollIntoView({ block: "end" });
          this.liveSocket.js().push(this.el, bottomEvent, {
            value: { id: lastChild.id },
            callback: () => {
              pendingOp = null;
              window.requestAnimationFrame(() => {
                if (!isWithinViewport(lastChild, this.scrollContainer)) {
                  lastChild.scrollIntoView({ block: "end" });
                }
              });
            }
          });
        }
      );
      this.throttles = [onTopOverrun, onFirstChildAtTop, onLastChildAtBottom];
      this.onScroll = (_e) => {
        const scrollNow = scrollTop(this.scrollContainer);
        if (pendingOp) {
          scrollBefore = scrollNow;
          return pendingOp();
        }
        const rect = this.findOverrunTarget();
        const topEvent = this.el.getAttribute(
          this.liveSocket.binding("viewport-top")
        );
        const bottomEvent = this.el.getAttribute(
          this.liveSocket.binding("viewport-bottom")
        );
        const lastChild = this.el.lastElementChild;
        const firstChild = this.el.firstElementChild;
        const isScrollingUp = scrollNow < scrollBefore;
        const isScrollingDown = scrollNow > scrollBefore;
        if (isScrollingUp && topEvent && !topOverran && rect.top >= 0) {
          topOverran = true;
          onTopOverrun(topEvent, firstChild);
        } else if (isScrollingDown && topOverran && rect.top <= 0) {
          topOverran = false;
        }
        if (topEvent && isScrollingUp && firstChild && isAtViewportTop(firstChild, this.scrollContainer)) {
          onFirstChildAtTop(topEvent, firstChild);
        } else if (bottomEvent && isScrollingDown && lastChild && isAtViewportBottom(lastChild, this.scrollContainer)) {
          onLastChildAtBottom(bottomEvent, lastChild);
        }
        scrollBefore = scrollNow;
      };
      if (this.scrollContainer) {
        this.scrollContainer.addEventListener("scroll", this.onScroll);
      } else {
        window.addEventListener("scroll", this.onScroll);
      }
    },
    updated() {
      if (this.scrollContainer && !this.scrollContainer.isConnected) {
        this.destroyed();
        this.mounted();
      }
    },
    destroyed() {
      this.throttles?.forEach((throttled) => throttled.cancel());
      this.throttles = null;
      if (this.scrollContainer) {
        this.scrollContainer.removeEventListener("scroll", this.onScroll);
      } else {
        window.removeEventListener("scroll", this.onScroll);
      }
    },
    throttle(interval, callback) {
      let lastCallAt = 0;
      let timer = null;
      const throttled = (...args) => {
        const now = Date.now();
        const remainingTime = interval - (now - lastCallAt);
        if (remainingTime <= 0 || remainingTime > interval) {
          if (timer !== null) {
            clearTimeout(timer);
            timer = null;
          }
          lastCallAt = now;
          callback(...args);
        } else if (timer === null) {
          timer = setTimeout(() => {
            lastCallAt = Date.now();
            timer = null;
            callback(...args);
          }, remainingTime);
        }
      };
      throttled.cancel = () => {
        if (timer !== null) {
          clearTimeout(timer);
          timer = null;
        }
      };
      return throttled;
    },
    findOverrunTarget() {
      let rect;
      const overrunTarget = this.el.getAttribute(
        this.liveSocket.binding(PHX_VIEWPORT_OVERRUN_TARGET)
      );
      if (overrunTarget) {
        const overrunEl = document.getElementById(overrunTarget);
        if (overrunEl) {
          rect = overrunEl.getBoundingClientRect();
        } else {
          throw new Error("did not find element with id " + overrunTarget);
        }
      } else {
        rect = this.el.getBoundingClientRect();
      }
      return rect;
    }
  };
  var LiveFileUpload = {
    activeRefs() {
      return this.el.getAttribute(PHX_ACTIVE_ENTRY_REFS);
    },
    preflightedRefs() {
      return this.el.getAttribute(PHX_PREFLIGHTED_REFS);
    },
    errorRefs() {
      return this.el.getAttribute(PHX_ERROR_REFS) || "";
    },
    hasSelectedFiles() {
      return (this.el.files?.length || 0) > 0 || LiveUploader.activeFiles(this.el).length > 0 || this.activeRefs() !== "" || this.errorRefs() !== "";
    },
    maybeRemoveRequired() {
      if (this.hasSelectedFiles()) {
        this.el.removeAttribute("required");
      }
    },
    mounted() {
      this.js().ignoreAttributes(this.el, ["value"]);
      this.preflightedWas = this.preflightedRefs();
      this.errorRefsWas = this.errorRefs();
      this.el.addEventListener("input", () => this.maybeRemoveRequired());
      this.maybeRemoveRequired();
    },
    updated() {
      const newPreflights = this.preflightedRefs();
      const newErrorRefs = this.errorRefs();
      if (this.errorRefsWas !== newErrorRefs) {
        this.errorRefsWas = newErrorRefs;
        if (newErrorRefs !== "") {
          this.__view().cancelSubmit(this.el.form, {
            reason: "entry-errors",
            inputs: [this.el]
          });
        }
      }
      if (this.preflightedWas !== newPreflights) {
        this.preflightedWas = newPreflights;
        if (newPreflights === "") {
          this.__view().cancelSubmit(this.el.form, {
            reason: "entries-removed",
            inputs: [this.el]
          });
        }
      }
      if (this.activeRefs() === "") {
        this.el.value = "";
      }
      this.maybeRemoveRequired();
      this.el.dispatchEvent(new CustomEvent(PHX_LIVE_FILE_UPDATED));
    }
  };
  var LiveImgPreview = {
    mounted() {
      this.ref = this.el.getAttribute("data-phx-entry-ref");
      this.inputEl = document.getElementById(
        this.el.getAttribute(PHX_UPLOAD_REF)
      );
      this.url = LiveUploader.getEntryDataURL(this.inputEl, this.ref);
      this.el.src = this.url;
    },
    destroyed() {
      URL.revokeObjectURL(this.url);
    }
  };
  var Hooks = {
    LiveFileUpload,
    LiveImgPreview,
    FocusWrap: {
      mounted() {
        this.focusStart = this.el.firstElementChild;
        this.focusEnd = this.el.lastElementChild;
        this.focusStart.addEventListener("focus", (e) => {
          if (!e.relatedTarget || !this.el.contains(e.relatedTarget)) {
            const nextFocus = e.target.nextElementSibling;
            aria_default.attemptFocus(nextFocus) || aria_default.focusFirst(nextFocus);
          } else {
            aria_default.focusLast(this.el);
          }
        });
        this.focusEnd.addEventListener("focus", (e) => {
          if (!e.relatedTarget || !this.el.contains(e.relatedTarget)) {
            const nextFocus = e.target.previousElementSibling;
            aria_default.attemptFocus(nextFocus) || aria_default.focusLast(nextFocus);
          } else {
            aria_default.focusFirst(this.el);
          }
        });
        if (!this.el.contains(document.activeElement)) {
          this.el.addEventListener("phx:show-end", () => this.el.focus());
          if (window.getComputedStyle(this.el).display !== "none") {
            aria_default.focusFirst(this.el);
          }
        }
      }
    },
    InfiniteScroll
  };
  var hooks_default = Hooks;
  var ElementRef = class _ElementRef {
    static onUnlock(el, callback) {
      const closestLock = el.closest(`[${PHX_REF_LOCK}]`);
      if (!closestLock) {
        return callback();
      }
      const ref = closestLock.getAttribute(PHX_REF_LOCK);
      const event = `phx:undo-lock:${ref}`;
      const onUnlock = (e) => {
        if (e.target !== closestLock)
          return;
        closestLock.removeEventListener(event, onUnlock);
        _ElementRef.onUnlock(el, callback);
      };
      closestLock.addEventListener(event, onUnlock);
    }
    constructor(el) {
      this.el = el;
      this.loadingRef = el.hasAttribute(PHX_REF_LOADING) ? parseInt(el.getAttribute(PHX_REF_LOADING), 10) : null;
      this.lockRef = el.hasAttribute(PHX_REF_LOCK) ? parseInt(el.getAttribute(PHX_REF_LOCK), 10) : null;
    }
    // public
    maybeUndo(ref, phxEvent, eachCloneCallback) {
      if (!this.isWithin(ref)) {
        dom_default.updatePrivate(this.el, PHX_PENDING_REFS, [], (pendingRefs) => {
          pendingRefs.push(ref);
          return pendingRefs;
        });
        return;
      }
      this.undoLocks(ref, phxEvent, eachCloneCallback);
      this.undoLoading(ref, phxEvent);
      dom_default.updatePrivate(this.el, PHX_PENDING_REFS, [], (pendingRefs) => {
        return pendingRefs.filter((pendingRef) => {
          let opts = {
            detail: { ref: pendingRef, event: phxEvent },
            bubbles: true,
            cancelable: false
          };
          if (this.loadingRef && this.loadingRef > pendingRef) {
            this.el.dispatchEvent(
              new CustomEvent(`phx:undo-loading:${pendingRef}`, opts)
            );
          }
          if (this.lockRef && this.lockRef > pendingRef) {
            this.el.dispatchEvent(
              new CustomEvent(`phx:undo-lock:${pendingRef}`, opts)
            );
          }
          return pendingRef > ref;
        });
      });
      if (this.isFullyResolvedBy(ref)) {
        this.el.removeAttribute(PHX_REF_SRC);
      }
    }
    // private
    isWithin(ref) {
      return !(this.loadingRef !== null && this.loadingRef > ref && this.lockRef !== null && this.lockRef > ref);
    }
    // Check for cloned PHX_REF_LOCK element that has been morphed behind
    // the scenes while this element was locked in the DOM.
    // When we apply the cloned tree to the active DOM element, we must
    //
    //   1. execute pending mounted hooks for nodes now in the DOM
    //   2. undo any ref inside the cloned tree that has since been ack'd
    undoLocks(ref, phxEvent, eachCloneCallback) {
      if (!this.isLockUndoneBy(ref)) {
        return;
      }
      const clonedTree = dom_default.private(this.el, PHX_REF_LOCK);
      if (clonedTree) {
        eachCloneCallback(clonedTree);
        dom_default.deletePrivate(this.el, PHX_REF_LOCK);
      }
      this.el.removeAttribute(PHX_REF_LOCK);
      const opts = {
        detail: { ref, event: phxEvent },
        bubbles: true,
        cancelable: false
      };
      this.el.dispatchEvent(
        new CustomEvent(`phx:undo-lock:${this.lockRef}`, opts)
      );
    }
    undoLoading(ref, phxEvent) {
      if (!this.isLoadingUndoneBy(ref)) {
        if (this.canUndoLoading(ref) && this.el.classList.contains("phx-submit-loading")) {
          this.el.classList.remove("phx-change-loading");
        }
        return;
      }
      if (this.canUndoLoading(ref)) {
        this.el.removeAttribute(PHX_REF_LOADING);
        const disabledVal = this.el.getAttribute(PHX_DISABLED);
        const readOnlyVal = this.el.getAttribute(PHX_READONLY);
        if (readOnlyVal !== null && "readOnly" in this.el) {
          this.el.readOnly = readOnlyVal === "true" ? true : false;
          this.el.removeAttribute(PHX_READONLY);
        }
        if (disabledVal !== null && "disabled" in this.el) {
          this.el.disabled = disabledVal === "true" ? true : false;
          this.el.removeAttribute(PHX_DISABLED);
        }
        const disableRestore = this.el.getAttribute(PHX_DISABLE_WITH_RESTORE);
        if (disableRestore !== null) {
          this.el.textContent = disableRestore;
          this.el.removeAttribute(PHX_DISABLE_WITH_RESTORE);
        }
        const opts = {
          detail: { ref, event: phxEvent },
          bubbles: true,
          cancelable: false
        };
        this.el.dispatchEvent(
          new CustomEvent(`phx:undo-loading:${this.loadingRef}`, opts)
        );
      }
      PHX_EVENT_CLASSES.forEach((name) => {
        if (name !== "phx-submit-loading" || this.canUndoLoading(ref)) {
          dom_default.removeClass(this.el, name);
        }
      });
    }
    isLoadingUndoneBy(ref) {
      return this.loadingRef === null ? false : this.loadingRef <= ref;
    }
    /** @internal */
    isLockUndoneBy(ref) {
      return this.lockRef === null ? false : this.lockRef <= ref;
    }
    isFullyResolvedBy(ref) {
      return (this.loadingRef === null || this.loadingRef <= ref) && (this.lockRef === null || this.lockRef <= ref);
    }
    // only remove the phx-submit-loading class if we are not locked
    canUndoLoading(ref) {
      return this.lockRef === null || this.lockRef <= ref;
    }
  };
  var DOMPostMorphRestorer = class {
    constructor(containerBefore, containerAfter, updateType) {
      const idsBefore = /* @__PURE__ */ new Set();
      const idsAfter = new Set(
        [...containerAfter.children].map((child) => child.id)
      );
      const elementsToModify = [];
      Array.from(containerBefore.children).forEach((child) => {
        if (child.id) {
          idsBefore.add(child.id);
          if (idsAfter.has(child.id)) {
            const previousElementId = child.previousElementSibling && child.previousElementSibling.id;
            elementsToModify.push({
              elementId: child.id,
              previousElementId
            });
          }
        }
      });
      this.containerId = containerAfter.id;
      this.updateType = updateType;
      this.elementsToModify = elementsToModify;
      this.elementIdsToAdd = [...idsAfter].filter((id) => !idsBefore.has(id));
    }
    // We do the following to optimize append/prepend operations:
    //   1) Track ids of modified elements & of new elements
    //   2) All the modified elements are put back in the correct position in the DOM tree
    //      by storing the id of their previous sibling
    //   3) New elements are going to be put in the right place by morphdom during append.
    //      For prepend, we move them to the first position in the container
    perform() {
      const container = dom_default.byId(this.containerId);
      if (!container) {
        return;
      }
      this.elementsToModify.forEach((elementToModify) => {
        if (elementToModify.previousElementId) {
          maybe(
            document.getElementById(elementToModify.previousElementId),
            (previousElem) => {
              maybe(
                document.getElementById(elementToModify.elementId),
                (elem) => {
                  const isInRightPlace = elem.previousElementSibling && elem.previousElementSibling.id == previousElem.id;
                  if (!isInRightPlace) {
                    previousElem.insertAdjacentElement("afterend", elem);
                  }
                }
              );
            }
          );
        } else {
          maybe(document.getElementById(elementToModify.elementId), (elem) => {
            const isInRightPlace = elem.previousElementSibling == null;
            if (!isInRightPlace) {
              container.insertAdjacentElement("afterbegin", elem);
            }
          });
        }
      });
      if (this.updateType == "prepend") {
        this.elementIdsToAdd.reverse().forEach((elemId) => {
          maybe(
            document.getElementById(elemId),
            (elem) => container.insertAdjacentElement("afterbegin", elem)
          );
        });
      }
    }
  };
  var DOCUMENT_FRAGMENT_NODE = 11;
  function morphAttrs(fromNode, toNode) {
    var toNodeAttrs = toNode.attributes;
    var attr;
    var attrName;
    var attrNamespaceURI;
    var attrValue;
    var fromValue;
    if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE || fromNode.nodeType === DOCUMENT_FRAGMENT_NODE) {
      return;
    }
    for (var i = toNodeAttrs.length - 1; i >= 0; i--) {
      attr = toNodeAttrs[i];
      attrName = attr.name;
      attrNamespaceURI = attr.namespaceURI;
      attrValue = attr.value;
      if (attrNamespaceURI) {
        attrName = attr.localName || attrName;
        fromValue = fromNode.getAttributeNS(attrNamespaceURI, attrName);
        if (fromValue !== attrValue) {
          if (attr.prefix === "xmlns") {
            attrName = attr.name;
          }
          fromNode.setAttributeNS(attrNamespaceURI, attrName, attrValue);
        }
      } else {
        fromValue = fromNode.getAttribute(attrName);
        if (fromValue !== attrValue) {
          fromNode.setAttribute(attrName, attrValue);
        }
      }
    }
    var fromNodeAttrs = fromNode.attributes;
    for (var d = fromNodeAttrs.length - 1; d >= 0; d--) {
      attr = fromNodeAttrs[d];
      attrName = attr.name;
      attrNamespaceURI = attr.namespaceURI;
      if (attrNamespaceURI) {
        attrName = attr.localName || attrName;
        if (!toNode.hasAttributeNS(attrNamespaceURI, attrName)) {
          fromNode.removeAttributeNS(attrNamespaceURI, attrName);
        }
      } else {
        if (!toNode.hasAttribute(attrName)) {
          fromNode.removeAttribute(attrName);
        }
      }
    }
  }
  var range;
  var NS_XHTML = "http://www.w3.org/1999/xhtml";
  var doc = typeof document === "undefined" ? void 0 : document;
  var HAS_TEMPLATE_SUPPORT = !!doc && "content" in doc.createElement("template");
  var HAS_RANGE_SUPPORT = !!doc && doc.createRange && "createContextualFragment" in doc.createRange();
  function createFragmentFromTemplate(str) {
    var template = doc.createElement("template");
    template.innerHTML = str;
    return template.content.childNodes[0];
  }
  function createFragmentFromRange(str) {
    if (!range) {
      range = doc.createRange();
      range.selectNode(doc.body);
    }
    var fragment = range.createContextualFragment(str);
    return fragment.childNodes[0];
  }
  function createFragmentFromWrap(str) {
    var fragment = doc.createElement("body");
    fragment.innerHTML = str;
    return fragment.childNodes[0];
  }
  function toElement(str) {
    str = str.trim();
    if (HAS_TEMPLATE_SUPPORT) {
      return createFragmentFromTemplate(str);
    } else if (HAS_RANGE_SUPPORT) {
      return createFragmentFromRange(str);
    }
    return createFragmentFromWrap(str);
  }
  function compareNodeNames(fromEl, toEl) {
    var fromNodeName = fromEl.nodeName;
    var toNodeName = toEl.nodeName;
    var fromCodeStart, toCodeStart;
    if (fromNodeName === toNodeName) {
      return true;
    }
    fromCodeStart = fromNodeName.charCodeAt(0);
    toCodeStart = toNodeName.charCodeAt(0);
    if (fromCodeStart <= 90 && toCodeStart >= 97) {
      return fromNodeName === toNodeName.toUpperCase();
    } else if (toCodeStart <= 90 && fromCodeStart >= 97) {
      return toNodeName === fromNodeName.toUpperCase();
    } else {
      return false;
    }
  }
  function createElementNS(name, namespaceURI) {
    return !namespaceURI || namespaceURI === NS_XHTML ? doc.createElement(name) : doc.createElementNS(namespaceURI, name);
  }
  function moveChildren(fromEl, toEl) {
    var curChild = fromEl.firstChild;
    while (curChild) {
      var nextChild = curChild.nextSibling;
      toEl.appendChild(curChild);
      curChild = nextChild;
    }
    return toEl;
  }
  function syncBooleanAttrProp(fromEl, toEl, name) {
    if (fromEl[name] !== toEl[name]) {
      fromEl[name] = toEl[name];
      if (fromEl[name]) {
        fromEl.setAttribute(name, "");
      } else {
        fromEl.removeAttribute(name);
      }
    }
  }
  var specialElHandlers_default = {
    OPTION: function(fromEl, toEl) {
      var parentNode = fromEl.parentNode;
      if (parentNode) {
        var parentName = parentNode.nodeName.toUpperCase();
        if (parentName === "OPTGROUP") {
          parentNode = parentNode.parentNode;
          parentName = parentNode && parentNode.nodeName.toUpperCase();
        }
        if (parentName === "SELECT" && !parentNode.hasAttribute("multiple")) {
          if (fromEl.hasAttribute("selected") && !toEl.selected) {
            fromEl.setAttribute("selected", "selected");
            fromEl.removeAttribute("selected");
          }
          parentNode.selectedIndex = -1;
        }
      }
      syncBooleanAttrProp(fromEl, toEl, "selected");
    },
    /**
     * The "value" attribute is special for the <input> element since it sets
     * the initial value. Changing the "value" attribute without changing the
     * "value" property will have no effect since it is only used to the set the
     * initial value.  Similar for the "checked" attribute, and "disabled".
     */
    INPUT: function(fromEl, toEl) {
      syncBooleanAttrProp(fromEl, toEl, "checked");
      syncBooleanAttrProp(fromEl, toEl, "disabled");
      if (fromEl.value !== toEl.value) {
        fromEl.value = toEl.value;
      }
      if (!toEl.hasAttribute("value")) {
        fromEl.removeAttribute("value");
      }
    },
    TEXTAREA: function(fromEl, toEl) {
      var newValue = toEl.value;
      if (fromEl.value !== newValue) {
        fromEl.value = newValue;
      }
      var firstChild = fromEl.firstChild;
      if (firstChild) {
        var oldValue = firstChild.nodeValue;
        if (oldValue == newValue || !newValue && oldValue == fromEl.placeholder) {
          return;
        }
        firstChild.nodeValue = newValue;
      }
    },
    SELECT: function(fromEl, toEl) {
      if (!toEl.hasAttribute("multiple")) {
        var selectedIndex = -1;
        var i = 0;
        var curChild = fromEl.firstChild;
        var optgroup;
        var nodeName;
        while (curChild) {
          nodeName = curChild.nodeName && curChild.nodeName.toUpperCase();
          if (nodeName === "OPTGROUP") {
            optgroup = curChild;
            curChild = optgroup.firstChild;
            if (!curChild) {
              curChild = optgroup.nextSibling;
              optgroup = null;
            }
          } else {
            if (nodeName === "OPTION") {
              if (curChild.hasAttribute("selected")) {
                selectedIndex = i;
                break;
              }
              i++;
            }
            curChild = curChild.nextSibling;
            if (!curChild && optgroup) {
              curChild = optgroup.nextSibling;
              optgroup = null;
            }
          }
        }
        fromEl.selectedIndex = selectedIndex;
      }
    }
  };
  var ELEMENT_NODE = 1;
  var DOCUMENT_FRAGMENT_NODE2 = 11;
  var TEXT_NODE = 3;
  var COMMENT_NODE = 8;
  function noop() {
  }
  function defaultGetNodeKey(node) {
    if (node) {
      return node.getAttribute && node.getAttribute("id") || node.id;
    }
  }
  function morphdomFactory(morphAttrs2) {
    return function morphdom2(fromNode, toNode, options) {
      if (!options) {
        options = {};
      }
      if (typeof toNode === "string") {
        if (fromNode.nodeName === "#document" || fromNode.nodeName === "HTML") {
          var toNodeHtml = toNode;
          toNode = doc.createElement("html");
          toNode.innerHTML = toNodeHtml;
        } else if (fromNode.nodeName === "BODY") {
          var toNodeBody = toNode;
          toNode = doc.createElement("html");
          toNode.innerHTML = toNodeBody;
          var bodyElement = toNode.querySelector("body");
          if (bodyElement) {
            toNode = bodyElement;
          }
        } else {
          toNode = toElement(toNode);
        }
      } else if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE2) {
        toNode = toNode.firstElementChild;
      }
      var getNodeKey = options.getNodeKey || defaultGetNodeKey;
      var onBeforeNodeAdded = options.onBeforeNodeAdded || noop;
      var onNodeAdded = options.onNodeAdded || noop;
      var onBeforeElUpdated = options.onBeforeElUpdated || noop;
      var onElUpdated = options.onElUpdated || noop;
      var onBeforeNodeDiscarded = options.onBeforeNodeDiscarded || noop;
      var onNodeDiscarded = options.onNodeDiscarded || noop;
      var onBeforeElChildrenUpdated = options.onBeforeElChildrenUpdated || noop;
      var skipFromChildren = options.skipFromChildren || noop;
      var addChild = options.addChild || function(parent, child) {
        return parent.appendChild(child);
      };
      var childrenOnly = options.childrenOnly === true;
      var keyedRoot = options.keyedRoot === true;
      var fromNodesLookup = /* @__PURE__ */ Object.create(null);
      var keyedRemovalList = [];
      function addKeyedRemoval(key) {
        keyedRemovalList.push(key);
      }
      function walkDiscardedChildNodes(node, skipKeyedNodes) {
        if (node.nodeType === ELEMENT_NODE) {
          var curChild = node.firstChild;
          while (curChild) {
            var key = void 0;
            if (skipKeyedNodes && (key = getNodeKey(curChild))) {
              addKeyedRemoval(key);
            } else {
              onNodeDiscarded(curChild);
              if (curChild.firstChild) {
                walkDiscardedChildNodes(curChild, skipKeyedNodes);
              }
            }
            curChild = curChild.nextSibling;
          }
        }
      }
      function removeNode(node, parentNode, skipKeyedNodes) {
        if (onBeforeNodeDiscarded(node) === false) {
          return;
        }
        if (parentNode) {
          parentNode.removeChild(node);
        }
        onNodeDiscarded(node);
        walkDiscardedChildNodes(node, skipKeyedNodes);
      }
      function indexTree(node) {
        if (node.nodeType === ELEMENT_NODE || node.nodeType === DOCUMENT_FRAGMENT_NODE2) {
          var curChild = node.firstChild;
          while (curChild) {
            var key = getNodeKey(curChild);
            if (key) {
              fromNodesLookup[key] = curChild;
            }
            indexTree(curChild);
            curChild = curChild.nextSibling;
          }
        }
      }
      indexTree(fromNode);
      function handleNodeAdded(el) {
        onNodeAdded(el);
        var curChild = el.firstChild;
        while (curChild) {
          var nextSibling = curChild.nextSibling;
          var key = getNodeKey(curChild);
          if (key) {
            var unmatchedFromEl = fromNodesLookup[key];
            if (unmatchedFromEl && compareNodeNames(curChild, unmatchedFromEl)) {
              curChild.parentNode.replaceChild(unmatchedFromEl, curChild);
              morphEl(unmatchedFromEl, curChild);
            } else {
              handleNodeAdded(curChild);
            }
          } else {
            handleNodeAdded(curChild);
          }
          curChild = nextSibling;
        }
      }
      function cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey) {
        while (curFromNodeChild) {
          var fromNextSibling = curFromNodeChild.nextSibling;
          if (curFromNodeKey = getNodeKey(curFromNodeChild)) {
            addKeyedRemoval(curFromNodeKey);
          } else {
            removeNode(
              curFromNodeChild,
              fromEl,
              true
              /* skip keyed nodes */
            );
          }
          curFromNodeChild = fromNextSibling;
        }
      }
      function morphEl(fromEl, toEl, childrenOnly2) {
        var toElKey = getNodeKey(toEl);
        if (toElKey) {
          delete fromNodesLookup[toElKey];
        }
        if (!childrenOnly2) {
          var beforeUpdateResult = onBeforeElUpdated(fromEl, toEl);
          if (beforeUpdateResult === false) {
            return;
          } else if (beforeUpdateResult instanceof Element) {
            fromEl = beforeUpdateResult;
            indexTree(fromEl);
          }
          morphAttrs2(fromEl, toEl);
          onElUpdated(fromEl);
          if (onBeforeElChildrenUpdated(fromEl, toEl) === false) {
            return;
          }
        }
        if (fromEl.nodeName !== "TEXTAREA") {
          morphChildren(fromEl, toEl);
        } else {
          specialElHandlers_default.TEXTAREA(fromEl, toEl);
        }
      }
      function morphChildren(fromEl, toEl) {
        var skipFrom = skipFromChildren(fromEl, toEl);
        var curToNodeChild = toEl.firstChild;
        var curFromNodeChild = fromEl.firstChild;
        var curToNodeKey;
        var curFromNodeKey;
        var fromNextSibling;
        var toNextSibling;
        var matchingFromEl;
        outer:
          while (curToNodeChild) {
            toNextSibling = curToNodeChild.nextSibling;
            curToNodeKey = getNodeKey(curToNodeChild);
            while (!skipFrom && curFromNodeChild) {
              fromNextSibling = curFromNodeChild.nextSibling;
              if (curToNodeChild.isSameNode && curToNodeChild.isSameNode(curFromNodeChild)) {
                curToNodeChild = toNextSibling;
                curFromNodeChild = fromNextSibling;
                continue outer;
              }
              curFromNodeKey = getNodeKey(curFromNodeChild);
              var curFromNodeType = curFromNodeChild.nodeType;
              var isCompatible = void 0;
              if (curFromNodeType === curToNodeChild.nodeType) {
                if (curFromNodeType === ELEMENT_NODE) {
                  if (curToNodeKey) {
                    if (curToNodeKey !== curFromNodeKey) {
                      if (matchingFromEl = fromNodesLookup[curToNodeKey]) {
                        if (fromNextSibling === matchingFromEl) {
                          isCompatible = false;
                        } else {
                          fromEl.insertBefore(matchingFromEl, curFromNodeChild);
                          if (curFromNodeKey) {
                            addKeyedRemoval(curFromNodeKey);
                          } else {
                            removeNode(
                              curFromNodeChild,
                              fromEl,
                              true
                              /* skip keyed nodes */
                            );
                          }
                          curFromNodeChild = matchingFromEl;
                          curFromNodeKey = getNodeKey(curFromNodeChild);
                        }
                      } else {
                        isCompatible = false;
                      }
                    }
                  } else if (curFromNodeKey) {
                    isCompatible = false;
                  }
                  isCompatible = isCompatible !== false && compareNodeNames(curFromNodeChild, curToNodeChild);
                  if (isCompatible) {
                    morphEl(curFromNodeChild, curToNodeChild);
                  }
                } else if (curFromNodeType === TEXT_NODE || curFromNodeType == COMMENT_NODE) {
                  isCompatible = true;
                  if (curFromNodeChild.nodeValue !== curToNodeChild.nodeValue) {
                    curFromNodeChild.nodeValue = curToNodeChild.nodeValue;
                  }
                }
              }
              if (isCompatible) {
                curToNodeChild = toNextSibling;
                curFromNodeChild = fromNextSibling;
                continue outer;
              }
              if (curFromNodeKey) {
                addKeyedRemoval(curFromNodeKey);
              } else {
                removeNode(
                  curFromNodeChild,
                  fromEl,
                  true
                  /* skip keyed nodes */
                );
              }
              curFromNodeChild = fromNextSibling;
            }
            if (curToNodeKey && (matchingFromEl = fromNodesLookup[curToNodeKey]) && compareNodeNames(matchingFromEl, curToNodeChild)) {
              if (!skipFrom) {
                addChild(fromEl, matchingFromEl);
              }
              morphEl(matchingFromEl, curToNodeChild);
            } else {
              var onBeforeNodeAddedResult = onBeforeNodeAdded(curToNodeChild);
              if (onBeforeNodeAddedResult !== false) {
                if (onBeforeNodeAddedResult) {
                  curToNodeChild = onBeforeNodeAddedResult;
                }
                if (curToNodeChild.actualize) {
                  curToNodeChild = curToNodeChild.actualize(fromEl.ownerDocument || doc);
                }
                addChild(fromEl, curToNodeChild);
                handleNodeAdded(curToNodeChild);
              }
            }
            curToNodeChild = toNextSibling;
            curFromNodeChild = fromNextSibling;
          }
        cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey);
        var specialElHandler = specialElHandlers_default[fromEl.nodeName];
        if (specialElHandler) {
          specialElHandler(fromEl, toEl);
        }
      }
      function cleanupKeyedNodes() {
        for (var i = 0, len = keyedRemovalList.length; i < len; i++) {
          var elToRemove = fromNodesLookup[keyedRemovalList[i]];
          if (elToRemove) {
            removeNode(elToRemove, elToRemove.parentNode, false);
          }
        }
      }
      if (keyedRoot && !childrenOnly) {
        var fromNodeKey = getNodeKey(fromNode);
        var toNodeKey = getNodeKey(toNode);
        if ((fromNodeKey || toNodeKey) && fromNodeKey !== toNodeKey) {
          if (toNode.actualize) {
            toNode = toNode.actualize(fromNode.ownerDocument || doc);
          }
          onNodeDiscarded(fromNode);
          if (fromNode.parentNode) {
            fromNode.parentNode.replaceChild(toNode, fromNode);
          }
          handleNodeAdded(toNode);
          walkDiscardedChildNodes(fromNode, false);
          cleanupKeyedNodes();
          return toNode;
        }
      }
      var morphedNode = fromNode;
      var morphedNodeType = morphedNode.nodeType;
      var toNodeType = toNode.nodeType;
      if (!childrenOnly) {
        if (morphedNodeType === ELEMENT_NODE) {
          if (toNodeType === ELEMENT_NODE) {
            if (!compareNodeNames(fromNode, toNode)) {
              onNodeDiscarded(fromNode);
              morphedNode = moveChildren(fromNode, createElementNS(toNode.nodeName, toNode.namespaceURI));
            }
          } else {
            morphedNode = toNode;
          }
        } else if (morphedNodeType === TEXT_NODE || morphedNodeType === COMMENT_NODE) {
          if (toNodeType === morphedNodeType) {
            if (morphedNode.nodeValue !== toNode.nodeValue) {
              morphedNode.nodeValue = toNode.nodeValue;
            }
            return morphedNode;
          } else {
            morphedNode = toNode;
          }
        }
      }
      if (morphedNode === toNode) {
        onNodeDiscarded(fromNode);
      } else {
        if (toNode.isSameNode && toNode.isSameNode(morphedNode)) {
          return;
        }
        morphEl(morphedNode, toNode, childrenOnly);
        cleanupKeyedNodes();
      }
      if (!childrenOnly && morphedNode !== fromNode && fromNode.parentNode) {
        if (morphedNode.actualize) {
          morphedNode = morphedNode.actualize(fromNode.ownerDocument || doc);
        }
        fromNode.parentNode.replaceChild(morphedNode, fromNode);
      }
      return morphedNode;
    };
  }
  var morphdom = morphdomFactory(morphAttrs);
  var index_default = morphdom;
  var DOMPatch = class {
    constructor(view, container, html, streams, targetCID, opts = {}) {
      this.view = view;
      this.liveSocket = view.liveSocket;
      this.container = container;
      this.rootID = view.root.id;
      this.html = html;
      this.streams = streams;
      this.streamInserts = {};
      this.streamComponentRestore = {};
      this.targetCID = targetCID;
      this.pendingRemoves = [];
      this.phxRemove = this.liveSocket.binding("remove");
      this.targetContainer = targetCID ? dom_default.getComponent(this.view.id, targetCID) : container;
      this.beforeUpdatedCallbacks = [];
      this.afterAddedCallbacks = [];
      this.afterUpdatedCallbacks = [];
      this.afterPhxChildAddedCallbacks = [];
      this.afterDiscardedCallbacks = [];
      this.afterTransitionsDiscardedCallbacks = [];
      this.withChildren = opts.withChildren || opts.undoRef !== void 0 || false;
      this.undoRef = opts.undoRef ?? null;
    }
    beforeUpdated(callback) {
      this.beforeUpdatedCallbacks.push(callback);
    }
    afterAdded(callback) {
      this.afterAddedCallbacks.push(callback);
    }
    afterUpdated(callback) {
      this.afterUpdatedCallbacks.push(callback);
    }
    afterPhxChildAdded(callback) {
      this.afterPhxChildAddedCallbacks.push(callback);
    }
    afterDiscarded(callback) {
      this.afterDiscardedCallbacks.push(callback);
    }
    afterTransitionsDiscarded(callback) {
      this.afterTransitionsDiscardedCallbacks.push(callback);
    }
    markPrunableContentForRemoval() {
      const phxUpdate = this.liveSocket.binding(PHX_UPDATE);
      dom_default.all(
        this.container,
        `[${phxUpdate}=append] > *, [${phxUpdate}=prepend] > *`,
        (el) => {
          el.setAttribute(PHX_PRUNE, "");
        }
      );
    }
    perform(isJoinPatch) {
      const { view, liveSocket: liveSocket2, html, container } = this;
      const reportError = (code, message, metadata, context) => view.logError(code, message, metadata, context);
      let targetContainer = this.targetContainer;
      if (this.targetCID) {
        const closestLock = targetContainer.closest(`[${PHX_REF_LOCK}]`);
        if (closestLock && !closestLock.isSameNode(targetContainer) && view.ownsElement(closestLock)) {
          const clonedTree = dom_default.private(closestLock, PHX_REF_LOCK);
          if (clonedTree) {
            targetContainer = clonedTree.querySelector(
              `[data-phx-component="${this.targetCID}"]`
            );
            if (!targetContainer)
              return;
          }
        }
      }
      const focused = liveSocket2.getActiveElement();
      const { selectionStart, selectionEnd } = focused && dom_default.hasSelectionRange(focused) ? focused : {};
      const phxUpdate = liveSocket2.binding(PHX_UPDATE);
      const phxViewportTop = liveSocket2.binding(PHX_VIEWPORT_TOP);
      const phxViewportBottom = liveSocket2.binding(PHX_VIEWPORT_BOTTOM);
      const phxTriggerExternal = liveSocket2.binding(PHX_TRIGGER_ACTION);
      const phxPatchFocused = liveSocket2.binding(PHX_PATCH_FOCUSED);
      const added = [];
      const updates = [];
      const appendPrependUpdates = [];
      let portalCallbacks = [];
      let externalFormTriggered = null;
      const morph = (targetContainer2, source, withChildren = this.withChildren) => {
        const morphCallbacks = {
          // normally, we are running with childrenOnly, as the patch HTML for a LV
          // does not include the LV attrs (data-phx-session, etc.)
          // when we are patching a live component, we do want to patch the root element as well;
          // another case is the recursive patch of a stream item that was kept on reset (-> onBeforeNodeAdded)
          childrenOnly: targetContainer2.getAttribute(PHX_COMPONENT) === null && !withChildren,
          keyedRoot: targetContainer2.getAttribute(PHX_COMPONENT) != null,
          getNodeKey: (node) => {
            if (!(node instanceof Element))
              return null;
            if (dom_default.isPhxDestroyed(node)) {
              return null;
            }
            if (isJoinPatch) {
              return node.id;
            }
            if (dom_default.private(node, "clientsideIdAttribute")) {
              return node.getAttribute(PHX_MAGIC_ID);
            }
            return node.id || node.getAttribute(PHX_MAGIC_ID);
          },
          // skip indexing from children when container is stream
          skipFromChildren: (from) => {
            return from.getAttribute(phxUpdate) === PHX_STREAM;
          },
          // tell morphdom how to add a child
          addChild: (parent, child) => {
            const { ref, streamAt } = this.getStreamInsert(child);
            if (ref === void 0) {
              return parent.appendChild(child);
            }
            this.setStreamRef(child, ref);
            if (streamAt === 0) {
              parent.insertAdjacentElement("afterbegin", child);
            } else if (streamAt === -1) {
              const lastChild = parent.lastElementChild;
              if (lastChild && !lastChild.hasAttribute(PHX_STREAM_REF)) {
                const nonStreamChild = parent.querySelector(
                  `:scope > :not([${PHX_STREAM_REF}])`
                );
                parent.insertBefore(child, nonStreamChild);
              } else {
                parent.appendChild(child);
              }
            } else if (streamAt > 0) {
              const sibling = parent.children[streamAt] ?? null;
              parent.insertBefore(child, sibling);
            }
          },
          onBeforeNodeAdded: (el) => {
            if (!(el instanceof Element)) {
              return el;
            }
            if (this.getStreamInsert(el)?.updateOnly && !this.streamComponentRestore[el.id]) {
              return false;
            }
            dom_default.maintainPrivateHooks(el, el, phxViewportTop, phxViewportBottom);
            let morphedEl = el;
            if (this.streamComponentRestore[el.id]) {
              morphedEl = this.streamComponentRestore[el.id];
              delete this.streamComponentRestore[el.id];
              morph(morphedEl, el, true);
            }
            return morphedEl;
          },
          onNodeAdded: (el) => {
            if (!(el instanceof Element)) {
              added.push(el);
              return;
            }
            this.maybeReOrderStream(el, true);
            if (dom_default.isPortalTemplate(el)) {
              portalCallbacks.push(() => this.teleport(el, morph));
            }
            if (el instanceof HTMLImageElement && el.srcset) {
              el.srcset = el.srcset;
            } else if (el instanceof HTMLVideoElement && el.autoplay) {
              el.play();
            }
            if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
              externalFormTriggered = el;
            }
            if (dom_default.isPhxChild(el) && view.ownsElement(el) || dom_default.isPhxSticky(el) && view.ownsElement(el.parentNode)) {
              this.trackAfterPhxChildAdded(el);
            }
            if (el.nodeName === "SCRIPT" && el.hasAttribute(PHX_RUNTIME_HOOK)) {
              el = this.handleRuntimeHook(el, source);
            }
            added.push(el);
          },
          onNodeDiscarded: (el) => this.onNodeDiscarded(el),
          onBeforeNodeDiscarded: (el) => {
            if (!(el instanceof Element)) {
              return true;
            }
            if (el.getAttribute(PHX_PRUNE) !== null) {
              return true;
            }
            if (el.parentElement !== null && el.id && dom_default.isPhxUpdate(el.parentElement, phxUpdate, [
              PHX_STREAM,
              "append",
              "prepend"
            ])) {
              return false;
            }
            if (el.getAttribute(PHX_TELEPORTED_REF)) {
              return false;
            }
            if (this.maybePendingRemove(el)) {
              return false;
            }
            if (this.skipCIDSibling(el)) {
              return false;
            }
            if (dom_default.isPortalTemplate(el)) {
              const teleportedEl = document.getElementById(
                el.content.firstElementChild?.id || ""
              );
              if (teleportedEl) {
                teleportedEl.remove();
                morphCallbacks.onNodeDiscarded(teleportedEl);
                this.view.dropPortalElementId(teleportedEl.id);
              }
            }
            return true;
          },
          onElUpdated: (el) => {
            if (dom_default.isNowTriggerFormExternal(el, phxTriggerExternal)) {
              externalFormTriggered = el;
            }
            updates.push(el);
            this.maybeReOrderStream(el, false);
          },
          onBeforeElUpdated: (fromEl, toEl) => {
            dom_default.syncPendingAttrs(fromEl, toEl);
            dom_default.maintainPrivateHooks(
              fromEl,
              toEl,
              phxViewportTop,
              phxViewportBottom
            );
            dom_default.cleanChildNodes(toEl, phxUpdate, reportError);
            const isFocusedFormEl = focused && fromEl.isSameNode(focused) && dom_default.isEditableInput(fromEl);
            const focusedSelectChanged = isFocusedFormEl && this.isChangedSelect(fromEl, toEl);
            if (this.skipCIDSibling(toEl)) {
              this.maybeCloneLockedElement(fromEl, isFocusedFormEl);
              this.copyNestedPrivateLock(fromEl, toEl);
              this.maybeReOrderStream(fromEl);
              return false;
            }
            if (dom_default.isPhxSticky(fromEl)) {
              [PHX_SESSION, PHX_STATIC, PHX_ROOT_ID].map((attr) => [
                attr,
                fromEl.getAttribute(attr),
                toEl.getAttribute(attr)
              ]).forEach(([attr, fromVal, toVal]) => {
                if (toVal && fromVal !== toVal) {
                  fromEl.setAttribute(attr, toVal);
                }
              });
              return false;
            }
            if (dom_default.isIgnored(fromEl, phxUpdate) || fromEl.form && fromEl.form.isSameNode(externalFormTriggered)) {
              this.trackBeforeUpdated(fromEl, toEl);
              dom_default.mergeAttrs(fromEl, toEl, {
                isIgnored: dom_default.isIgnored(fromEl, phxUpdate)
              });
              updates.push(fromEl);
              dom_default.applyStickyOperations(fromEl);
              return false;
            }
            if (fromEl.type === "number" && fromEl.validity && fromEl.validity.badInput) {
              return false;
            }
            fromEl = this.maybeCloneLockedElement(fromEl, isFocusedFormEl);
            if (dom_default.isPhxChild(toEl)) {
              const prevSession = fromEl.getAttribute(PHX_SESSION);
              dom_default.mergeAttrs(fromEl, toEl, { exclude: [PHX_STATIC] });
              if (prevSession !== "") {
                fromEl.setAttribute(PHX_SESSION, prevSession);
              }
              fromEl.setAttribute(PHX_ROOT_ID, this.rootID);
              dom_default.applyStickyOperations(fromEl);
              return false;
            }
            this.copyNestedPrivateLock(fromEl, toEl);
            dom_default.copyPrivates(toEl, fromEl);
            if (dom_default.isPortalTemplate(toEl)) {
              portalCallbacks.push(() => this.teleport(toEl, morph));
              fromEl.content.replaceChildren(toEl.content.cloneNode(true));
              return false;
            }
            if (isFocusedFormEl && fromEl.type !== "hidden" && !focusedSelectChanged && !toEl.hasAttribute(phxPatchFocused)) {
              this.trackBeforeUpdated(fromEl, toEl);
              dom_default.mergeFocusedInput(fromEl, toEl);
              dom_default.syncAttrsToProps(fromEl);
              updates.push(fromEl);
              dom_default.applyStickyOperations(fromEl);
              return false;
            } else {
              if (focusedSelectChanged) {
                fromEl.blur();
              }
              if (dom_default.isPhxUpdate(toEl, phxUpdate, ["append", "prepend"])) {
                appendPrependUpdates.push(
                  new DOMPostMorphRestorer(
                    fromEl,
                    toEl,
                    toEl.getAttribute(phxUpdate)
                  )
                );
              }
              dom_default.syncAttrsToProps(toEl);
              dom_default.applyStickyOperations(toEl);
              this.trackBeforeUpdated(fromEl, toEl);
              return fromEl;
            }
          }
        };
        index_default(targetContainer2, source, morphCallbacks);
      };
      this.trackBeforeUpdated(container, container);
      liveSocket2.time("morphdom", () => {
        this.streams.forEach(([ref, inserts, deleteIds, reset]) => {
          inserts.forEach(([key, streamAt, limit, updateOnly]) => {
            this.streamInserts[key] = { ref, streamAt, limit, reset, updateOnly };
          });
          if (reset !== void 0) {
            dom_default.all(document, `[${PHX_STREAM_REF}="${ref}"]`, (child) => {
              this.removeStreamChildElement(child);
            });
          }
          deleteIds.forEach((id) => {
            const child = document.getElementById(id);
            if (child) {
              this.removeStreamChildElement(child);
            }
          });
        });
        if (isJoinPatch) {
          dom_default.all(this.container, `[${phxUpdate}=${PHX_STREAM}]`).filter((el) => this.view.ownsElement(el)).forEach((el) => {
            Array.from(el.children).forEach((child) => {
              this.removeStreamChildElement(child, true);
            });
          });
        }
        morph(targetContainer, html);
        let teleportCount = 0;
        while (portalCallbacks.length > 0 && teleportCount < 5) {
          const copy = portalCallbacks.slice();
          portalCallbacks = [];
          copy.forEach((callback) => callback());
          teleportCount++;
        }
        this.view.portalElementIds.forEach((id) => {
          const el = document.getElementById(id);
          if (el) {
            const srcId = el.getAttribute(PHX_TELEPORTED_SRC);
            if (srcId) {
              const source = document.getElementById(srcId);
              if (!source) {
                el.remove();
                this.onNodeDiscarded(el);
                this.view.dropPortalElementId(id);
              }
            }
          }
        });
      });
      if (liveSocket2.isDebugEnabled()) {
        detectDuplicateIds(reportError);
        detectInvalidStreamInserts(this.streamInserts, reportError);
        Array.from(document.querySelectorAll("input[name=id]")).forEach(
          (node) => {
            if (node instanceof HTMLInputElement && node.form) {
              reportError(
                "dom.form-input-name-id",
                'Detected an input with name="id" inside a form! This will cause problems when patching the DOM.\n',
                { el: node },
                { attribution: "app" }
              );
            }
          }
        );
      }
      if (appendPrependUpdates.length > 0) {
        liveSocket2.time("post-morph append/prepend restoration", () => {
          appendPrependUpdates.forEach((update) => update.perform());
        });
      }
      liveSocket2.silenceEvents(
        () => dom_default.restoreFocus(focused, selectionStart, selectionEnd)
      );
      dom_default.dispatchEvent(document, "phx:update");
      added.forEach((el) => this.trackAfterAdded(el));
      updates.forEach((el) => this.trackAfterUpdated(el));
      this.transitionPendingRemoves();
      if (externalFormTriggered) {
        liveSocket2.unload();
        const submitter = dom_default.private(externalFormTriggered, "submitter");
        if (submitter && submitter.name && targetContainer.contains(submitter)) {
          const input = document.createElement("input");
          input.type = "hidden";
          const formId = submitter.getAttribute("form");
          if (formId) {
            input.setAttribute("form", formId);
          }
          input.name = submitter.name;
          input.value = submitter.value;
          submitter.parentElement.insertBefore(input, submitter);
        }
        Object.getPrototypeOf(externalFormTriggered).submit.call(
          externalFormTriggered
        );
      }
      return true;
    }
    trackBeforeUpdated(fromEl, toEl) {
      this.beforeUpdatedCallbacks.forEach((cb) => cb(fromEl, toEl));
    }
    trackAfterAdded(el) {
      this.afterAddedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterUpdated(el) {
      this.afterUpdatedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterPhxChildAdded(el) {
      this.afterPhxChildAddedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterDiscarded(el) {
      this.afterDiscardedCallbacks.forEach((cb) => cb(el));
    }
    trackAfterTransitionsDiscarded(els) {
      this.afterTransitionsDiscardedCallbacks.forEach((cb) => cb(els));
    }
    onNodeDiscarded(el) {
      if (dom_default.isPhxChild(el) || dom_default.isPhxSticky(el)) {
        this.liveSocket.destroyViewByEl(el);
      }
      this.trackAfterDiscarded(el);
    }
    maybePendingRemove(node) {
      if (node.getAttribute && node.getAttribute(this.phxRemove) !== null) {
        this.pendingRemoves.push(node);
        return true;
      } else {
        return false;
      }
    }
    removeStreamChildElement(child, force = false) {
      if (!force && !this.view.ownsElement(child)) {
        return;
      }
      if (this.streamInserts[child.id]) {
        this.streamComponentRestore[child.id] = child;
        child.remove();
      } else {
        if (!this.maybePendingRemove(child)) {
          child.remove();
          this.onNodeDiscarded(child);
        }
      }
    }
    getStreamInsert(el) {
      const insert = el.id ? this.streamInserts[el.id] : {};
      return insert || {};
    }
    setStreamRef(el, ref) {
      dom_default.putSticky(
        el,
        PHX_STREAM_REF,
        (el2) => el2.setAttribute(PHX_STREAM_REF, ref)
      );
    }
    maybeReOrderStream(el, isNew = false) {
      const { ref, streamAt, reset } = this.getStreamInsert(el);
      if (streamAt === void 0) {
        return;
      }
      this.setStreamRef(el, ref);
      if (!reset && !isNew) {
        return;
      }
      if (!el.parentElement) {
        return;
      }
      if (streamAt === 0) {
        this.moveOrInsertBefore(
          el.parentElement,
          el,
          el.parentElement.firstElementChild
        );
      } else if (streamAt > 0) {
        const children = Array.from(el.parentElement.children);
        const oldIndex = children.indexOf(el);
        if (streamAt >= children.length - 1) {
          this.moveOrInsertBefore(el.parentElement, el, null);
        } else {
          const sibling = children[streamAt];
          if (oldIndex > streamAt) {
            this.moveOrInsertBefore(el.parentElement, el, sibling);
          } else {
            this.moveOrInsertBefore(
              el.parentElement,
              el,
              sibling.nextElementSibling
            );
          }
        }
      }
      this.maybeLimitStream(el);
    }
    // Reorder a child within its parent. When supported, use the atomic
    // moveBefore (https://developer.mozilla.org/en-US/docs/Web/API/Node/moveBefore)
    // so connected custom elements (and other state-bearing nodes like iframes)
    // are not disconnected and reconnected by the move. Falls back to
    // insertBefore otherwise. Passing `ref === null` moves to the end.
    // See also https://github.com/phoenixframework/phoenix_live_view/issues/4212.
    moveOrInsertBefore(parent, child, ref) {
      if (typeof parent.moveBefore === "function") {
        try {
          parent.moveBefore(child, ref);
          return;
        } catch {
        }
      }
      parent.insertBefore(child, ref);
    }
    maybeLimitStream(el) {
      const { limit } = this.getStreamInsert(el);
      if (limit !== null) {
        const children = Array.from(el.parentElement.children);
        if (limit < 0 && children.length > limit * -1) {
          children.slice(0, children.length + limit).forEach((child) => this.removeStreamChildElement(child));
        } else if (limit >= 0 && children.length > limit) {
          children.slice(limit).forEach((child) => this.removeStreamChildElement(child));
        }
      }
    }
    transitionPendingRemoves() {
      const { pendingRemoves, liveSocket: liveSocket2 } = this;
      if (pendingRemoves.length > 0) {
        liveSocket2.transitionRemoves(pendingRemoves, this.view, () => {
          pendingRemoves.forEach((el) => {
            const child = dom_default.firstPhxChild(el);
            if (child) {
              liveSocket2.destroyViewByEl(child);
            }
            el.remove();
          });
          this.trackAfterTransitionsDiscarded(pendingRemoves);
        });
      }
    }
    isChangedSelect(fromEl, toEl) {
      if (!(fromEl instanceof HTMLSelectElement) || fromEl.multiple) {
        return false;
      }
      if (fromEl.options.length !== toEl.options.length) {
        return true;
      }
      toEl.value = fromEl.value;
      return !fromEl.isEqualNode(toEl);
    }
    skipCIDSibling(el) {
      return el.nodeType === Node.ELEMENT_NODE && el.hasAttribute(PHX_SKIP);
    }
    maybeCloneLockedElement(fromEl, isFocusedFormEl) {
      if (!fromEl.hasAttribute(PHX_REF_SRC))
        return fromEl;
      const ref = new ElementRef(fromEl);
      if (!fromEl.hasAttribute(PHX_REF_LOCK) || this.undoRef !== null && ref.isLockUndoneBy(this.undoRef)) {
        return fromEl;
      }
      dom_default.applyStickyOperations(fromEl);
      const clone2 = fromEl.hasAttribute(PHX_REF_LOCK) ? dom_default.private(fromEl, PHX_REF_LOCK) || fromEl.cloneNode(true) : null;
      if (!clone2)
        return fromEl;
      dom_default.putPrivate(fromEl, PHX_REF_LOCK, clone2);
      return isFocusedFormEl ? fromEl : clone2;
    }
    copyNestedPrivateLock(fromEl, toEl) {
      if (this.undoRef === null || !dom_default.private(toEl, PHX_REF_LOCK))
        return;
      dom_default.putPrivate(fromEl, PHX_REF_LOCK, dom_default.private(toEl, PHX_REF_LOCK));
    }
    teleport(el, morph) {
      const targetSelector = el.getAttribute(PHX_PORTAL);
      const portalContainer = document.querySelector(targetSelector);
      if (!portalContainer) {
        throw new Error(
          "portal target with selector " + targetSelector + " not found"
        );
      }
      const toTeleport = el.content.firstElementChild;
      if (this.skipCIDSibling(toTeleport)) {
        return;
      }
      if (!toTeleport?.id) {
        throw new Error(
          "phx-portal template must have a single root element with ID!"
        );
      }
      const existing = document.getElementById(toTeleport.id);
      let portalTarget;
      if (existing) {
        if (!portalContainer.contains(existing)) {
          portalContainer.appendChild(existing);
        }
        portalTarget = existing;
      } else {
        portalTarget = document.createElementNS(
          toTeleport.namespaceURI,
          toTeleport.localName
        );
        portalContainer.appendChild(portalTarget);
      }
      toTeleport.setAttribute(PHX_TELEPORTED_REF, this.view.id);
      toTeleport.setAttribute(PHX_TELEPORTED_SRC, el.id);
      morph(portalTarget, toTeleport.cloneNode(true), true);
      toTeleport.removeAttribute(PHX_TELEPORTED_REF);
      toTeleport.removeAttribute(PHX_TELEPORTED_SRC);
      this.view.pushPortalElementId(toTeleport.id);
    }
    handleRuntimeHook(el, source) {
      const name = el.getAttribute(PHX_RUNTIME_HOOK);
      let nonce = el.hasAttribute("nonce") ? el.getAttribute("nonce") : null;
      if (el.hasAttribute("nonce")) {
        const template = document.createElement("template");
        template.innerHTML = source;
        nonce = template.content.querySelector(`script[${PHX_RUNTIME_HOOK}="${CSS.escape(name)}"]`)?.getAttribute("nonce") ?? null;
      }
      const script = document.createElement("script");
      script.textContent = el.textContent;
      dom_default.mergeAttrs(script, el, { isIgnored: false });
      if (nonce) {
        script.nonce = nonce;
      }
      el.replaceWith(script);
      return script;
    }
  };
  var VOID_TAGS = /* @__PURE__ */ new Set([
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr"
  ]);
  var quoteChars = /* @__PURE__ */ new Set(["'", '"']);
  var modifyRoot = (html, attrs, clearInnerHTML) => {
    let i;
    let insideComment;
    let beforeTag, afterTag, tag, tagNameEndsAt, id, newHTML;
    const lookahead = html.match(/^(\s*(?:<!--.*?-->\s*)*)<([^\s\/>]+)/);
    if (lookahead === null) {
      throw new Error(`malformed html ${html}`);
    }
    i = lookahead[0].length;
    beforeTag = lookahead[1];
    tag = lookahead[2];
    tagNameEndsAt = i;
    for (i; i < html.length; i++) {
      if (html.charAt(i) === ">") {
        break;
      }
      if (html.charAt(i) === "=") {
        const isId = html.slice(i - 3, i) === " id";
        i++;
        const char = html.charAt(i);
        if (quoteChars.has(char)) {
          const attrStartsAt = i;
          i++;
          for (i; i < html.length; i++) {
            if (html.charAt(i) === char) {
              break;
            }
          }
          if (isId) {
            id = html.slice(attrStartsAt + 1, i);
            break;
          }
        }
      }
    }
    let closeAt = html.length - 1;
    insideComment = false;
    while (closeAt >= beforeTag.length + tag.length) {
      const char = html.charAt(closeAt);
      if (insideComment) {
        if (char === "-" && html.slice(closeAt - 3, closeAt) === "<!-") {
          insideComment = false;
          closeAt -= 4;
        } else {
          closeAt -= 1;
        }
      } else if (char === ">" && html.slice(closeAt - 2, closeAt) === "--") {
        insideComment = true;
        closeAt -= 3;
      } else if (char === ">") {
        break;
      } else {
        closeAt -= 1;
      }
    }
    afterTag = html.slice(closeAt + 1, html.length);
    const attrsStr = Object.keys(attrs).map((attr) => attrs[attr] === true ? attr : `${attr}="${attrs[attr]}"`).join(" ");
    if (clearInnerHTML) {
      const idAttrStr = id ? ` id="${id}"` : "";
      if (VOID_TAGS.has(tag)) {
        newHTML = `<${tag}${idAttrStr}${attrsStr === "" ? "" : " "}${attrsStr}/>`;
      } else {
        newHTML = `<${tag}${idAttrStr}${attrsStr === "" ? "" : " "}${attrsStr}></${tag}>`;
      }
    } else {
      const rest = html.slice(tagNameEndsAt, closeAt + 1);
      newHTML = `<${tag}${attrsStr === "" ? "" : " "}${attrsStr}${rest}`;
    }
    return [newHTML, beforeTag, afterTag];
  };
  var RenderingBuffer = class {
    constructor(_preMerge, _cid) {
      this.html = "";
      this.pending = [];
    }
    /**
     * Characters written so far, counting what an open root was split off from.
     * A buffer that records positions brackets spans with this.
     *
     * Summed on read rather than tracked on write: only a buffer that records
     * positions ever asks, and tracking it charged every render that never does.
     * Roots nest shallowly, so the walk is short.
     */
    get length() {
      let total = this.html.length;
      for (let i = 0; i < this.pending.length; i++) {
        total += this.pending[i].length;
      }
      return total;
    }
    write(str) {
      this.html += str;
    }
    toString() {
      return this.html;
    }
    /**
     * Brackets a root element: everything written in between is a single
     * element, `attrs` are added to its start tag, and `clearInnerHTML`
     * additionally discards its contents (LiveView skips re-rendering a root
     * that did not change and reuses what is already in the DOM).
     *
     * The default isolates the element so it can rewrite it without touching
     * what came before. A buffer that records positions overrides both, keeping
     * it continuous and applying its edits at the end instead; `length` stays
     * continuous across the pair either way.
     */
    beginRoot() {
      this.pending.push(this.html);
      this.html = "";
    }
    endRoot(attrs, clearInnerHTML) {
      const [root, before, after] = modifyRoot(this.html, attrs, clearInnerHTML);
      this.html = this.pending.pop() + before + root + after;
    }
    /**
     * Brackets the dynamic at `statics[index]` of `node`. Called around every
     * dynamic of every render, so the default has to be cheap; see
     * {@link ReportingBuffer} for what a buffer can do with it.
     */
    enter(_node, _index, _statics) {
    }
    exit() {
    }
    /**
     * Brackets one entry of a keyed comprehension. Entries hold dynamics without
     * being one themselves, so they are opened separately from `enter`.
     */
    beginKeyedEntry(_index) {
    }
    endKeyedEntry() {
    }
  };
  var ALL_CHANGED = Symbol("all changed");
  var ReportingBuffer = class extends RenderingBuffer {
    constructor(preMerge, cid) {
      super(preMerge, cid);
      this.frames = [];
      this.cursors = [];
      this.diff = this.cursorFor(preMerge, cid);
    }
    // Cloning is not optional: the merge adopts diff subtrees into the rendered
    // tree and then mutates them. The copy is shared by every buffer of the
    // render that follows, so nothing here may consume it.
    static preMerge(diff) {
      return deepClone(diff);
    }
    cursorFor(preMerge, cid) {
      if (!preMerge) {
        return void 0;
      } else if (cid === null) {
        return preMerge;
      } else {
        return preMerge[COMPONENTS] && preMerge[COMPONENTS][cid];
      }
    }
    /**
     * Called around every dynamic in the tree. A change is reported at every
     * level, so a dynamic containing a changed one is itself reported as
     * changed; a buffer that wants to attribute a change to the innermost thing
     * that changed applies that policy itself, walking `frames`.
     */
    onEnter(_frame) {
    }
    onExit(_frame) {
    }
    /** Where in the diff the renderer currently is. */
    currentDiff() {
      return this.cursors.length > 0 ? this.cursors[this.cursors.length - 1] : this.diff;
    }
    enter(node, index, statics) {
      const diff = this.diffFor(this.currentDiff(), index);
      const frame = {
        node,
        index,
        statics,
        changed: diff !== void 0
      };
      this.cursors.push(diff);
      this.frames.push(frame);
      this.onEnter(frame);
    }
    exit() {
      this.cursors.pop();
      this.onExit(this.frames.pop());
    }
    beginKeyedEntry(index) {
      this.cursors.push(this.keyedEntry(this.currentDiff(), index));
    }
    endKeyedEntry() {
      this.cursors.pop();
    }
    keyedEntry(diffNode, index) {
      const keyed = this.diffFor(diffNode, KEYED);
      if (keyed === ALL_CHANGED || keyed === void 0) {
        return keyed;
      }
      const entry = keyed[index];
      if (Array.isArray(entry)) {
        return entry[1];
      } else if (typeof entry === "number") {
        return void 0;
      } else {
        return entry;
      }
    }
    diffFor(diffNode, key) {
      if (diffNode === void 0 || diffNode === null) {
        return void 0;
      } else if (diffNode === ALL_CHANGED || diffNode[STATIC] !== void 0) {
        return ALL_CHANGED;
      } else {
        return diffNode[key];
      }
    }
  };
  var Rendered = class {
    static extract(diff) {
      const { [REPLY]: reply, [EVENTS]: events, [TITLE]: title } = diff;
      delete diff[REPLY];
      delete diff[EVENTS];
      delete diff[TITLE];
      return { diff, title, reply: reply || null, events: events || [] };
    }
    // The buffer class is read afresh on every merge and every render rather
    // than held, so one installed after this tree mounted still takes effect —
    // for the parts of the page the next patch renders, and no sooner.
    constructor(viewId, rendered, bufferClass = () => RenderingBuffer) {
      this.viewId = viewId;
      this.rendered = {};
      this.magicId = 0;
      this.bufferClass = bufferClass;
      this.initialMerge = true;
      this.mergeDiff(rendered);
      this.initialMerge = false;
    }
    parentViewId() {
      return this.viewId;
    }
    toString(onlyCids) {
      const { buffer: str, streams } = this.recursiveToString(
        this.rendered,
        this.rendered[COMPONENTS],
        onlyCids,
        true,
        {},
        null
      );
      return { buffer: str, streams };
    }
    // cid identifies the subtree being rendered to the buffer: null for the root
    // tree, a component id otherwise.
    recursiveToString(rendered, components = rendered[COMPONENTS], onlyCids, changeTracking, rootAttrs, cid) {
      onlyCids = onlyCids ? new Set(onlyCids) : null;
      const bufferClass = this.bufferClass();
      const [mergedBy, preMerge] = this.bufferPreMerge;
      const buffer = new bufferClass(
        mergedBy === bufferClass ? preMerge : void 0,
        cid
      );
      const output = {
        buffer,
        components,
        onlyCids,
        streams: /* @__PURE__ */ new Set()
      };
      this.toOutputBuffer(rendered, null, output, changeTracking, rootAttrs);
      return { buffer: buffer.toString(), streams: output.streams };
    }
    componentCIDs(diff) {
      return Object.keys(diff[COMPONENTS] || {}).map((i) => parseInt(i));
    }
    isComponentOnlyDiff(diff) {
      if (!diff[COMPONENTS]) {
        return false;
      }
      return Object.keys(diff).length === 1;
    }
    getComponent(diff, cid) {
      return diff[COMPONENTS][cid];
    }
    resetRender(cid) {
      if (this.rendered[COMPONENTS][cid]) {
        this.rendered[COMPONENTS][cid].reset = true;
      }
    }
    mergeDiff(diff) {
      const bufferClass = this.bufferClass();
      this.bufferPreMerge = [
        bufferClass,
        !this.initialMerge && bufferClass.preMerge ? bufferClass.preMerge(diff) : void 0
      ];
      const newc = diff[COMPONENTS];
      const cache = {};
      delete diff[COMPONENTS];
      this.rendered = this.mutableMerge(this.rendered, diff);
      this.rendered[COMPONENTS] = this.rendered[COMPONENTS] || {};
      if (newc) {
        const oldc = this.rendered[COMPONENTS];
        for (const cid in newc) {
          newc[cid] = this.cachedFindComponent(cid, newc[cid], oldc, newc, cache);
        }
        for (const cid in newc) {
          oldc[cid] = newc[cid];
        }
        diff[COMPONENTS] = newc;
      }
    }
    cachedFindComponent(cid, cdiff, oldc, newc, cache) {
      if (cache[cid]) {
        return cache[cid];
      } else {
        let ndiff, stat, scid = cdiff[STATIC];
        if (isCid(scid)) {
          let tdiff;
          if (scid > 0) {
            tdiff = this.cachedFindComponent(scid, newc[scid], oldc, newc, cache);
          } else {
            tdiff = oldc[-scid];
          }
          stat = tdiff[STATIC];
          ndiff = this.cloneMerge(tdiff, cdiff, true);
          ndiff[STATIC] = stat;
        } else {
          ndiff = cdiff[STATIC] !== void 0 || oldc[cid] === void 0 ? cdiff : this.cloneMerge(oldc[cid], cdiff, false);
        }
        cache[cid] = ndiff;
        return ndiff;
      }
    }
    mutableMerge(target, source) {
      if (source[STATIC] !== void 0) {
        return source;
      } else {
        this.doMutableMerge(target, source);
        return target;
      }
    }
    doMutableMerge(target, source) {
      if (source[KEYED]) {
        this.mergeKeyed(target, source);
      } else {
        for (const key in source) {
          const val = source[key];
          const targetVal = target[key];
          const isObjVal = isObject(val);
          if (isObjVal && val[STATIC] === void 0 && isObject(targetVal)) {
            this.doMutableMerge(targetVal, val);
          } else {
            target[key] = val;
          }
        }
      }
      if (target[ROOT]) {
        target.newRender = true;
      }
    }
    clone(diff) {
      return deepClone(diff);
    }
    // keyed comprehensions
    mergeKeyed(target, source) {
      const clonedTarget = source[KEYED][KEYED_MOVED] && this.clone(target);
      Object.entries(source[KEYED]).forEach(([i, entry]) => {
        if (i === KEYED_COUNT || i === KEYED_MOVED) {
          return;
        }
        if (Array.isArray(entry)) {
          const [old_idx, diff] = entry;
          target[KEYED][i] = clonedTarget[KEYED][old_idx];
          this.doMutableMerge(target[KEYED][i], diff);
        } else if (typeof entry === "number") {
          const old_idx = entry;
          target[KEYED][i] = clonedTarget[KEYED][old_idx];
        } else if (typeof entry === "object") {
          if (!target[KEYED][i]) {
            target[KEYED][i] = {};
          }
          this.doMutableMerge(target[KEYED][i], entry);
        }
      });
      if (source[KEYED][KEYED_COUNT] < target[KEYED][KEYED_COUNT]) {
        for (let i = source[KEYED][KEYED_COUNT]; i < target[KEYED][KEYED_COUNT]; i++) {
          delete target[KEYED][i];
        }
      }
      target[KEYED][KEYED_COUNT] = source[KEYED][KEYED_COUNT];
      if (source[STREAM]) {
        target[STREAM] = source[STREAM];
      }
      if (source[TEMPLATES]) {
        target[TEMPLATES] = source[TEMPLATES];
      }
    }
    // Merges cid trees together, copying statics from source tree.
    //
    // The `pruneMagicId` is passed to control pruning the magicId of the
    // target. We must always prune the magicId when we are sharing statics
    // from another component. If not pruning, we replicate the logic from
    // mutableMerge, where we set newRender to true if there is a root
    // (effectively forcing the new version to be rendered instead of skipped)
    //
    cloneMerge(target, source, pruneMagicId) {
      let merged;
      if (source[KEYED]) {
        merged = this.clone(target);
        this.mergeKeyed(merged, source);
        if (pruneMagicId) {
          this.pruneInternalIds(merged);
        }
      } else {
        merged = { ...target, ...source };
        for (const key in merged) {
          const val = source[key];
          const targetVal = target[key];
          if (isObject(val) && val[STATIC] === void 0 && isObject(targetVal)) {
            merged[key] = this.cloneMerge(targetVal, val, pruneMagicId);
          } else if (val === void 0 && isObject(targetVal)) {
            merged[key] = this.cloneMerge(targetVal, {}, pruneMagicId);
          }
        }
      }
      if (pruneMagicId) {
        this.deleteInternalIds(merged);
      } else if (target[ROOT]) {
        merged.newRender = true;
      }
      return merged;
    }
    // A component sharing statics with another cid is cloned from that cid's
    // tree, which would otherwise carry that cid's magic IDs along. They identify
    // the node they came from, so a duplicate would be wrong for as long as the
    // clone lives.
    pruneInternalIds(rendered) {
      for (const key in rendered) {
        if (isObject(rendered[key])) {
          this.pruneInternalIds(rendered[key]);
        }
      }
      this.deleteInternalIds(rendered);
    }
    deleteInternalIds(rendered) {
      delete rendered.magicId;
      delete rendered.newRender;
    }
    componentToString(cid) {
      const { buffer: str, streams } = this.recursiveCIDToString(
        this.rendered[COMPONENTS],
        cid,
        null
      );
      const [strippedHTML, _before, _after] = modifyRoot(str, {});
      return { buffer: strippedHTML, streams };
    }
    pruneCIDs(cids) {
      cids.forEach((cid) => delete this.rendered[COMPONENTS][cid]);
    }
    // private
    get() {
      return this.rendered;
    }
    isNewFingerprint(diff = {}) {
      return !!diff[STATIC];
    }
    templateStatic(part, templates) {
      if (typeof part === "number") {
        return templates[part];
      } else {
        return part;
      }
    }
    nextMagicID() {
      this.magicId++;
      return `m${this.magicId}-${this.parentViewId()}`;
    }
    // Converts rendered tree to output buffer.
    //
    // changeTracking controls if we can apply the PHX_SKIP optimization.
    toOutputBuffer(rendered, templates, output, changeTracking, rootAttrs = {}) {
      if (rendered[KEYED]) {
        return this.comprehensionToBuffer(
          rendered,
          templates,
          output,
          changeTracking
        );
      }
      if (rendered[TEMPLATES]) {
        templates = rendered[TEMPLATES];
        delete rendered[TEMPLATES];
      }
      let { [STATIC]: statics } = rendered;
      statics = this.templateStatic(statics, templates);
      rendered[STATIC] = statics;
      const isRoot = rendered[ROOT];
      if (isRoot) {
        output.buffer.beginRoot();
      }
      if (changeTracking && isRoot && !rendered.magicId) {
        rendered.newRender = true;
        rendered.magicId = this.nextMagicID();
      }
      this.dynamicsToBuffer(rendered, statics, templates, output, changeTracking);
      if (isRoot) {
        let skip = false;
        let attrs;
        if (changeTracking || rendered.magicId) {
          skip = changeTracking && !rendered.newRender;
          attrs = { [PHX_MAGIC_ID]: rendered.magicId, ...rootAttrs };
        } else {
          attrs = rootAttrs;
        }
        if (skip) {
          attrs[PHX_SKIP] = true;
        }
        output.buffer.endRoot(attrs, skip);
        rendered.newRender = false;
      }
    }
    // Emits `statics` interleaved with the dynamics held on `node`, which is
    // either a rendered struct or a single entry of a keyed comprehension.
    //
    // Every dynamic is opened and closed on the buffer, whether or not the buffer
    // does anything with it. Skipping that for buffers that do not care was worth
    // ~4-6% of render on component-heavy trees and nothing on any other shape,
    // which is under 1% of a patch once the DOM work around it is counted — not
    // worth a capability flag a buffer can forget to set.
    dynamicsToBuffer(node, statics, templates, output, changeTracking) {
      const buffer = output.buffer;
      for (let i = 0; i < statics.length - 1; i++) {
        buffer.write(statics[i]);
        buffer.enter(node, i, statics);
        this.dynamicToBuffer(node[i], templates, output, changeTracking);
        buffer.exit();
      }
      buffer.write(statics[statics.length - 1]);
    }
    comprehensionToBuffer(rendered, templates, output, changeTracking) {
      const keyedTemplates = templates || rendered[TEMPLATES];
      const statics = this.templateStatic(rendered[STATIC], templates);
      rendered[STATIC] = statics;
      delete rendered[TEMPLATES];
      for (let i = 0; i < rendered[KEYED][KEYED_COUNT]; i++) {
        output.buffer.beginKeyedEntry(i);
        this.dynamicsToBuffer(
          rendered[KEYED][i],
          statics,
          keyedTemplates,
          output,
          changeTracking
        );
        output.buffer.endKeyedEntry();
      }
      if (rendered[STREAM]) {
        const stream = rendered[STREAM];
        const [_ref, _inserts, deleteIds, reset] = stream;
        if (rendered[KEYED][KEYED_COUNT] > 0 || deleteIds.length > 0 || reset) {
          delete rendered[STREAM];
          rendered[KEYED] = {
            [KEYED_COUNT]: 0
          };
          output.streams.add(stream);
        }
      }
    }
    dynamicToBuffer(rendered, templates, output, changeTracking) {
      if (typeof rendered === "number") {
        const { buffer: str, streams } = this.recursiveCIDToString(
          output.components,
          rendered,
          output.onlyCids
        );
        output.buffer.write(str);
        for (const s of streams) {
          output.streams.add(s);
        }
      } else if (isObject(rendered)) {
        this.toOutputBuffer(rendered, templates, output, changeTracking, {});
      } else {
        output.buffer.write(rendered);
      }
    }
    recursiveCIDToString(components, cid, onlyCids) {
      if (components[cid]) {
        const component = components[cid];
        const attrs = { [PHX_COMPONENT]: cid, [PHX_VIEW_REF]: this.viewId };
        const skip = onlyCids && !onlyCids.has(cid);
        component.newRender = !skip;
        component.magicId = `c${cid}-${this.parentViewId()}`;
        const changeTracking = !component.reset;
        const { buffer: html, streams } = this.recursiveToString(
          component,
          components,
          onlyCids,
          changeTracking,
          attrs,
          cid
        );
        delete component.reset;
        return { buffer: html, streams };
      } else {
        logError(
          "render.missing-component",
          `no component for CID ${cid}`,
          {
            cid,
            components
          },
          { viewId: this.viewId, attribution: "internal" }
        );
        throw new Error(
          "Cannot continue render due to missing component: " + cid
        );
      }
    }
  };
  var focusStack = [];
  var default_transition_time = 200;
  var JS = {
    // private
    exec(e, eventType, phxEvent, view, sourceEl, defaults) {
      const [defaultKind, defaultArgs] = defaults || [
        null,
        { callback: defaults && defaults.callback }
      ];
      const commands = Array.isArray(phxEvent) ? phxEvent : typeof phxEvent === "string" && phxEvent.startsWith("[") ? JSON.parse(phxEvent) : [[defaultKind, defaultArgs]];
      commands.forEach(([kind, args]) => {
        if (kind === defaultKind) {
          args = { ...defaultArgs, ...args };
          args.callback = args.callback || defaultArgs.callback;
        }
        this.filterToEls(view.liveSocket, sourceEl, args).forEach((el) => {
          this[`exec_${kind}`](e, eventType, phxEvent, view, sourceEl, el, args);
        });
      });
    },
    isVisible(el) {
      return !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);
    },
    // returns true if any part of the element is inside the viewport
    isInViewport(el) {
      const rect = el.getBoundingClientRect();
      const windowHeight = window.innerHeight || document.documentElement.clientHeight;
      const windowWidth = window.innerWidth || document.documentElement.clientWidth;
      return rect.right > 0 && rect.bottom > 0 && rect.left < windowWidth && rect.top < windowHeight;
    },
    // private
    // commands
    exec_exec(e, eventType, phxEvent, view, sourceEl, el, { attr, to }) {
      const encodedJS = el.getAttribute(attr);
      if (!encodedJS) {
        throw new Error(`expected ${attr} to contain JS command on "${to}"`);
      }
      view.liveSocket.execJS(el, encodedJS, eventType);
    },
    exec_dispatch(e, eventType, phxEvent, view, sourceEl, el, { event, detail, bubbles, blocking }) {
      detail = detail || {};
      detail.dispatcher = sourceEl;
      if (blocking) {
        const promise = new Promise((resolve, _reject) => {
          detail.done = resolve;
        });
        view.liveSocket.asyncTransition(promise);
      }
      dom_default.dispatchEvent(el, event, { detail, bubbles });
    },
    exec_push(e, eventType, phxEvent, view, sourceEl, el, args) {
      const {
        event,
        data,
        target,
        page_loading,
        loading,
        value,
        dispatcher,
        callback
      } = args;
      const pushOpts = {
        loading,
        value,
        target,
        page_loading: !!page_loading,
        originalEvent: e
      };
      const targetSrc = eventType === "change" && dispatcher ? dispatcher : sourceEl;
      const phxTarget = target || targetSrc.getAttribute(view.binding("target")) || targetSrc;
      const handler = (targetView, targetCtx) => {
        if (!targetView.isConnected()) {
          return;
        }
        if (eventType === "change") {
          let { newCid, _target } = args;
          _target = _target || (dom_default.isFormAssociated(sourceEl) ? sourceEl.name : void 0);
          if (_target) {
            pushOpts._target = _target;
          }
          targetView.pushInput(
            sourceEl,
            targetCtx,
            newCid,
            event || phxEvent,
            pushOpts,
            callback
          );
        } else if (eventType === "submit") {
          const { submitter } = args;
          targetView.submitForm(
            sourceEl,
            targetCtx,
            event || phxEvent,
            submitter,
            pushOpts,
            callback
          );
        } else {
          targetView.pushEvent(
            eventType,
            sourceEl,
            targetCtx,
            event || phxEvent,
            data,
            pushOpts,
            callback
          );
        }
      };
      if (args.targetView && args.targetCtx) {
        handler(args.targetView, args.targetCtx);
      } else {
        view.withinTargets(phxTarget, handler);
      }
    },
    exec_navigate(e, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
      view.liveSocket.historyRedirect(
        e,
        href,
        replace ? "replace" : "push",
        null,
        sourceEl
      );
    },
    exec_patch(e, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
      view.liveSocket.pushHistoryPatch(
        e,
        href,
        replace ? "replace" : "push",
        sourceEl
      );
    },
    exec_focus(e, eventType, phxEvent, view, sourceEl, el) {
      this.focusWithRetry(() => aria_default.attemptFocus(el));
    },
    exec_focus_first(e, eventType, phxEvent, view, sourceEl, el) {
      this.focusWithRetry(
        () => aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el)
      );
    },
    exec_push_focus(e, eventType, phxEvent, view, sourceEl, el) {
      if (view.isDestroyed()) {
        return;
      }
      focusStack.push({ el: el || sourceEl, view });
    },
    exec_pop_focus(_e, _eventType, _phxEvent, view, _sourceEl, _el) {
      if (view.isDestroyed()) {
        return;
      }
      const focusEntry = focusStack.pop();
      if (focusEntry) {
        const { el } = focusEntry;
        this.focusWithRetry(() => el.focus());
      }
    },
    focusWithRetry(callback) {
      callback();
      const activeElement = document.activeElement;
      window.requestAnimationFrame(() => {
        window.requestAnimationFrame(() => {
          if (document.activeElement === activeElement) {
            callback();
          }
        });
      });
    },
    dropFocus(view) {
      let dropped = 0;
      for (let i = focusStack.length - 1; i >= 0; i--) {
        if (focusStack[i].view === view) {
          focusStack.splice(i, 1);
          dropped++;
        }
      }
      return dropped;
    },
    exec_add_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.addOrRemoveClasses(el, names, [], transition, time, view, blocking);
    },
    exec_remove_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.addOrRemoveClasses(el, [], names, transition, time, view, blocking);
    },
    exec_toggle_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
      this.toggleClasses(el, names, transition, time, view, blocking);
    },
    exec_toggle_attr(e, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val1, val2] }) {
      this.toggleAttr(el, attr, val1, val2);
    },
    exec_ignore_attrs(e, eventType, phxEvent, view, sourceEl, el, { attrs }) {
      this.ignoreAttrs(el, attrs);
    },
    exec_transition(e, eventType, phxEvent, view, sourceEl, el, { time, transition, blocking }) {
      this.addOrRemoveClasses(el, [], [], transition, time, view, blocking);
    },
    exec_toggle(e, eventType, phxEvent, view, sourceEl, el, { display, ins, outs, time, blocking }) {
      this.toggle(eventType, view, el, display, ins, outs, time, blocking);
    },
    exec_show(e, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
      this.show(eventType, view, el, display, transition, time, blocking);
    },
    exec_hide(e, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
      this.hide(eventType, view, el, display, transition, time, blocking);
    },
    exec_set_attr(e, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val] }) {
      this.setOrRemoveAttrs(el, [[attr, val]], []);
    },
    exec_remove_attr(e, eventType, phxEvent, view, sourceEl, el, { attr }) {
      this.setOrRemoveAttrs(el, [], [attr]);
    },
    ignoreAttrs(el, attrs) {
      dom_default.putPrivate(el, "JS:ignore_attrs", {
        apply: (fromEl, toEl) => {
          let fromAttributes = Array.from(fromEl.attributes);
          let fromAttributeNames = fromAttributes.map((attr) => attr.name);
          Array.from(toEl.attributes).filter((attr) => {
            return !fromAttributeNames.includes(attr.name);
          }).forEach((attr) => {
            if (dom_default.attributeIgnored(attr, attrs)) {
              toEl.removeAttribute(attr.name);
            }
          });
          fromAttributes.forEach((attr) => {
            if (dom_default.attributeIgnored(attr, attrs)) {
              toEl.setAttribute(attr.name, attr.value);
            }
          });
        }
      });
    },
    onBeforeElUpdated(fromEl, toEl) {
      const ignoreAttrs = dom_default.private(fromEl, "JS:ignore_attrs");
      if (ignoreAttrs) {
        ignoreAttrs.apply(fromEl, toEl);
      }
    },
    // utils for commands
    show(eventType, view, el, display, transition, time, blocking) {
      if (!this.isVisible(el)) {
        this.toggle(
          eventType,
          view,
          el,
          display,
          transition,
          null,
          time,
          blocking
        );
      }
    },
    hide(eventType, view, el, display, transition, time, blocking) {
      if (this.isVisible(el)) {
        this.toggle(
          eventType,
          view,
          el,
          display,
          null,
          transition,
          time,
          blocking
        );
      }
    },
    toggle(eventType, view, el, display, ins, outs, time, blocking) {
      time = time == null ? default_transition_time : time;
      const [inClasses, inStartClasses, inEndClasses] = ins || [[], [], []];
      const [outClasses, outStartClasses, outEndClasses] = outs || [[], [], []];
      if (inClasses.length > 0 || outClasses.length > 0) {
        if (this.isVisible(el)) {
          const onStart = () => {
            this.addOrRemoveClasses(
              el,
              outStartClasses,
              inClasses.concat(inStartClasses).concat(inEndClasses)
            );
            window.requestAnimationFrame(() => {
              this.addOrRemoveClasses(el, outClasses, []);
              window.requestAnimationFrame(
                () => this.addOrRemoveClasses(el, outEndClasses, outStartClasses)
              );
            });
          };
          const onEnd = () => {
            this.addOrRemoveClasses(el, [], outClasses.concat(outEndClasses));
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = "none"
            );
            el.dispatchEvent(new Event("phx:hide-end"));
          };
          el.dispatchEvent(new Event("phx:hide-start"));
          if (blocking === false) {
            onStart();
            setTimeout(onEnd, time);
          } else {
            view.transition(time, onStart, onEnd);
          }
        } else {
          if (eventType === "remove") {
            return;
          }
          const onStart = () => {
            this.addOrRemoveClasses(
              el,
              inStartClasses,
              outClasses.concat(outStartClasses).concat(outEndClasses)
            );
            const stickyDisplay = display || this.defaultDisplay(el);
            window.requestAnimationFrame(() => {
              this.addOrRemoveClasses(el, inClasses, []);
              window.requestAnimationFrame(() => {
                dom_default.putSticky(
                  el,
                  "toggle",
                  (currentEl) => currentEl.style.display = stickyDisplay
                );
                this.addOrRemoveClasses(el, inEndClasses, inStartClasses);
              });
            });
          };
          const onEnd = () => {
            this.addOrRemoveClasses(el, [], inClasses.concat(inEndClasses));
            el.dispatchEvent(new Event("phx:show-end"));
          };
          el.dispatchEvent(new Event("phx:show-start"));
          if (blocking === false) {
            onStart();
            setTimeout(onEnd, time);
          } else {
            view.transition(time, onStart, onEnd);
          }
        }
      } else {
        if (this.isVisible(el)) {
          window.requestAnimationFrame(() => {
            el.dispatchEvent(new Event("phx:hide-start"));
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = "none"
            );
            el.dispatchEvent(new Event("phx:hide-end"));
          });
        } else {
          window.requestAnimationFrame(() => {
            el.dispatchEvent(new Event("phx:show-start"));
            const stickyDisplay = display || this.defaultDisplay(el);
            dom_default.putSticky(
              el,
              "toggle",
              (currentEl) => currentEl.style.display = stickyDisplay
            );
            el.dispatchEvent(new Event("phx:show-end"));
          });
        }
      }
    },
    toggleClasses(el, classes, transition, time, view, blocking) {
      window.requestAnimationFrame(() => {
        const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
        const newAdds = classes.filter(
          (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
        );
        const newRemoves = classes.filter(
          (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
        );
        this.addOrRemoveClasses(
          el,
          newAdds,
          newRemoves,
          transition,
          time,
          view,
          blocking
        );
      });
    },
    toggleAttr(el, attr, val1, val2) {
      if (el.hasAttribute(attr)) {
        if (val2 !== void 0) {
          if (el.getAttribute(attr) === val1) {
            this.setOrRemoveAttrs(el, [[attr, val2]], []);
          } else {
            this.setOrRemoveAttrs(el, [[attr, val1]], []);
          }
        } else {
          this.setOrRemoveAttrs(el, [], [attr]);
        }
      } else {
        this.setOrRemoveAttrs(el, [[attr, val1]], []);
      }
    },
    addOrRemoveClasses(el, adds, removes, transition, time, view, blocking) {
      time = time == null ? default_transition_time : time;
      const [transitionRun, transitionStart, transitionEnd] = transition || [
        [],
        [],
        []
      ];
      if (transitionRun.length > 0) {
        const onStart = () => {
          this.addOrRemoveClasses(
            el,
            transitionStart,
            [].concat(transitionRun).concat(transitionEnd)
          );
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, transitionRun, []);
            window.requestAnimationFrame(
              () => this.addOrRemoveClasses(el, transitionEnd, transitionStart)
            );
          });
        };
        const onDone = () => this.addOrRemoveClasses(
          el,
          adds.concat(transitionEnd),
          removes.concat(transitionRun).concat(transitionStart)
        );
        if (blocking === false) {
          onStart();
          setTimeout(onDone, time);
        } else {
          view.transition(time, onStart, onDone);
        }
        return;
      }
      window.requestAnimationFrame(() => {
        const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
        const keepAdds = adds.filter(
          (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
        );
        const keepRemoves = removes.filter(
          (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
        );
        const newAdds = prevAdds.filter((name) => removes.indexOf(name) < 0).concat(keepAdds);
        const newRemoves = prevRemoves.filter((name) => adds.indexOf(name) < 0).concat(keepRemoves);
        dom_default.putSticky(el, "classes", (currentEl) => {
          currentEl.classList.remove(...newRemoves);
          currentEl.classList.add(...newAdds);
          return [newAdds, newRemoves];
        });
      });
    },
    setOrRemoveAttrs(el, sets, removes) {
      const [prevSets, prevRemoves] = dom_default.getSticky(el, "attrs", [[], []]);
      const alteredAttrs = sets.map(([attr, _val]) => attr).concat(removes);
      const newSets = prevSets.filter(([attr, _val]) => !alteredAttrs.includes(attr)).concat(sets);
      const newRemoves = prevRemoves.filter((attr) => !alteredAttrs.includes(attr)).concat(removes);
      if (sets.some(([attr, val]) => attr === "id" && el.getAttribute("id") !== val)) {
        dom_default.putPrivate(el, "clientsideIdAttribute", true);
      }
      dom_default.putSticky(el, "attrs", (currentEl) => {
        newRemoves.forEach((attr) => currentEl.removeAttribute(attr));
        newSets.forEach(([attr, val]) => currentEl.setAttribute(attr, val));
        return [newSets, newRemoves];
      });
    },
    hasAllClasses(el, classes) {
      return classes.every((name) => el.classList.contains(name));
    },
    isToggledOut(el, outClasses) {
      return !this.isVisible(el) || this.hasAllClasses(el, outClasses);
    },
    filterToEls(liveSocket2, sourceEl, { to }) {
      const defaultQuery = () => {
        if (typeof to === "string") {
          return document.querySelectorAll(to);
        } else if (to.closest) {
          const toEl = sourceEl.closest(to.closest);
          return toEl ? [toEl] : [];
        } else if (to.inner) {
          return sourceEl.querySelectorAll(to.inner);
        }
      };
      return to ? liveSocket2.jsQuerySelectorAll(sourceEl, to, defaultQuery) : [sourceEl];
    },
    defaultDisplay(el) {
      return { tr: "table-row", td: "table-cell" }[el.tagName.toLowerCase()] || "block";
    },
    transitionClasses(val) {
      if (!val) {
        return null;
      }
      let [trans, tStart, tEnd] = Array.isArray(val) ? val : [val.split(" "), [], []];
      trans = Array.isArray(trans) ? trans : trans.split(" ");
      tStart = Array.isArray(tStart) ? tStart : tStart.split(" ");
      tEnd = Array.isArray(tEnd) ? tEnd : tEnd.split(" ");
      return [trans, tStart, tEnd];
    }
  };
  var js_default = JS;
  var js_commands_default = (liveSocket2, eventType) => {
    return {
      exec(el, encodedJS) {
        liveSocket2.execJS(el, encodedJS, eventType);
      },
      show(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.show(
          eventType,
          owner,
          el,
          opts.display,
          js_default.transitionClasses(opts.transition),
          opts.time,
          opts.blocking
        );
      },
      hide(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.hide(
          eventType,
          owner,
          el,
          null,
          js_default.transitionClasses(opts.transition),
          opts.time,
          opts.blocking
        );
      },
      toggle(el, opts = {}) {
        const owner = liveSocket2.owner(el);
        const inTransition = js_default.transitionClasses(opts.in);
        const outTransition = js_default.transitionClasses(opts.out);
        js_default.toggle(
          eventType,
          owner,
          el,
          opts.display,
          inTransition,
          outTransition,
          opts.time,
          opts.blocking
        );
      },
      addClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          classNames,
          [],
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      removeClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          [],
          classNames,
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      toggleClass(el, names, opts = {}) {
        const classNames = Array.isArray(names) ? names : names.split(" ");
        const owner = liveSocket2.owner(el);
        js_default.toggleClasses(
          el,
          classNames,
          js_default.transitionClasses(opts.transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      transition(el, transition, opts = {}) {
        const owner = liveSocket2.owner(el);
        js_default.addOrRemoveClasses(
          el,
          [],
          [],
          js_default.transitionClasses(transition),
          opts.time,
          owner,
          opts.blocking
        );
      },
      setAttribute(el, attr, val) {
        js_default.setOrRemoveAttrs(el, [[attr, val]], []);
      },
      removeAttribute(el, attr) {
        js_default.setOrRemoveAttrs(el, [], [attr]);
      },
      toggleAttribute(el, attr, val1, val2) {
        js_default.toggleAttr(el, attr, val1, val2);
      },
      push(el, type, opts = {}) {
        liveSocket2.withinOwners(el, (view) => {
          const { value, ...rest } = opts;
          const data = value || {};
          let e = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
          js_default.exec(e, eventType, type, view, el, ["push", { data, ...rest }]);
        });
      },
      navigate(href, opts = {}) {
        ensureSameOrigin(href, "navigate");
        const customEvent = new CustomEvent("phx:exec");
        liveSocket2.historyRedirect(
          customEvent,
          href,
          opts.replace ? "replace" : "push",
          null,
          null
        );
      },
      patch(href, opts = {}) {
        ensureSameOrigin(href, "patch");
        const customEvent = new CustomEvent("phx:exec");
        liveSocket2.pushHistoryPatch(
          customEvent,
          href,
          opts.replace ? "replace" : "push",
          null
        );
      },
      ignoreAttributes(el, attrs) {
        js_default.ignoreAttrs(el, Array.isArray(attrs) ? attrs : [attrs]);
      }
    };
  };
  var HOOK_ID = "hookId";
  var DEAD_HOOK = "deadHook";
  var viewHookID = 1;
  var ViewHook = class _ViewHook {
    get liveSocket() {
      return this.__liveSocket();
    }
    /** @internal */
    static makeID() {
      return viewHookID++;
    }
    /** @internal */
    static elementID(el) {
      return dom_default.private(el, HOOK_ID);
    }
    /** @internal */
    static deadHook(el) {
      return dom_default.private(el, DEAD_HOOK) === true;
    }
    /** @internal */
    constructor(view, el, callbacks) {
      this.el = el;
      this.__attachView(view);
      this.__listeners = /* @__PURE__ */ new Set();
      this.__isDisconnected = false;
      dom_default.putPrivate(this.el, HOOK_ID, _ViewHook.makeID());
      if (view && view.isDead) {
        dom_default.putPrivate(this.el, DEAD_HOOK, true);
      }
      if (callbacks) {
        const protectedProps = /* @__PURE__ */ new Set([
          "el",
          "liveSocket",
          "__view",
          "__listeners",
          "__isDisconnected",
          "constructor",
          // Standard object properties
          // Core ViewHook API methods
          "js",
          "pushEvent",
          "pushEventTo",
          "handleEvent",
          "removeHandleEvent",
          "upload",
          "uploadTo",
          // Internal lifecycle callers
          "__mounted",
          "__updated",
          "__beforeUpdate",
          "__destroyed",
          "__reconnected",
          "__disconnected",
          "__cleanup__"
        ]);
        for (const key in callbacks) {
          if (Object.prototype.hasOwnProperty.call(callbacks, key)) {
            this[key] = callbacks[key];
            if (protectedProps.has(key)) {
              console.warn(
                `Hook object for element #${el.id} overwrites core property '${key}'!`
              );
            }
          }
        }
        const lifecycleMethods = [
          "mounted",
          "beforeUpdate",
          "updated",
          "destroyed",
          "disconnected",
          "reconnected"
        ];
        lifecycleMethods.forEach((methodName) => {
          if (callbacks[methodName] && typeof callbacks[methodName] === "function") {
            this[methodName] = callbacks[methodName];
          }
        });
      }
    }
    /** @internal */
    __attachView(view) {
      if (view) {
        this.__view = () => view;
        this.__liveSocket = () => view.liveSocket;
      } else {
        this.__view = () => {
          throw new Error(
            `hook not yet attached to a live view: ${this.el.outerHTML}`
          );
        };
        this.__liveSocket = () => {
          throw new Error(
            `hook not yet attached to a live view: ${this.el.outerHTML}`
          );
        };
      }
    }
    // Default lifecycle methods
    mounted() {
    }
    beforeUpdate(_toEl) {
    }
    updated() {
    }
    destroyed() {
    }
    disconnected() {
    }
    reconnected() {
    }
    // Internal lifecycle callers - called by the View
    /** @internal */
    __mounted() {
      this.mounted();
    }
    /** @internal */
    __updated() {
      this.updated();
    }
    /** @internal */
    __beforeUpdate(toEl) {
      this.beforeUpdate(toEl);
    }
    /** @internal */
    __destroyed() {
      this.destroyed();
      dom_default.deletePrivate(this.el, HOOK_ID);
    }
    /** @internal */
    __reconnected() {
      if (this.__isDisconnected) {
        this.__isDisconnected = false;
        this.reconnected();
      }
    }
    /** @internal */
    __disconnected() {
      if (!this.__isDisconnected) {
        this.__isDisconnected = true;
        this.disconnected();
      }
    }
    js() {
      return {
        ...js_commands_default(this.__view().liveSocket, "hook"),
        exec: (encodedJS) => {
          this.__view().liveSocket.execJS(this.el, encodedJS, "hook");
        }
      };
    }
    pushEvent(event, payload, onReply) {
      const promise = this.__view().pushHookEvent(
        this.el,
        null,
        event,
        payload || {}
      );
      if (onReply === void 0) {
        return promise.then(({ reply }) => reply);
      }
      promise.then(
        ({ reply, ref }) => onReply(reply, ref),
        () => {
        }
      );
    }
    pushEventTo(selectorOrTarget, event, payload, onReply) {
      if (onReply === void 0) {
        const targetPair = [];
        this.__view().withinTargets(
          selectorOrTarget,
          (view, targetCtx) => {
            targetPair.push({ view, targetCtx });
          }
        );
        const promises = targetPair.map(({ view, targetCtx }) => {
          return view.pushHookEvent(
            this.el,
            targetCtx,
            event,
            payload || {}
          );
        });
        return Promise.allSettled(promises);
      }
      this.__view().withinTargets(
        selectorOrTarget,
        (view, targetCtx) => {
          view.pushHookEvent(this.el, targetCtx, event, payload || {}).then(
            ({ reply, ref }) => onReply(reply, ref),
            () => {
            }
          );
        }
      );
    }
    handleEvent(event, callback) {
      const callbackRef = {
        event,
        callback: (customEvent) => callback(customEvent.detail)
      };
      window.addEventListener(
        `phx:${event}`,
        callbackRef.callback
      );
      this.__listeners.add(callbackRef);
      return callbackRef;
    }
    removeHandleEvent(ref) {
      window.removeEventListener(
        `phx:${ref.event}`,
        ref.callback
      );
      this.__listeners.delete(ref);
    }
    upload(name, files) {
      return this.__view().dispatchUploads(null, name, files);
    }
    uploadTo(selectorOrTarget, name, files) {
      return this.__view().withinTargets(
        selectorOrTarget,
        (view, targetCtx) => {
          view.dispatchUploads(targetCtx, name, files);
        }
      );
    }
    /** @internal */
    __cleanup__() {
      this.__listeners.forEach(
        (callbackRef) => this.removeHandleEvent(callbackRef)
      );
    }
  };
  var prependFormDataKey = (key, prefix) => {
    const isArray = key.endsWith("[]");
    let baseKey = isArray ? key.slice(0, -2) : key;
    baseKey = baseKey.replace(/([^\[\]]+)(\]?$)/, `${prefix}$1$2`);
    if (isArray) {
      baseKey += "[]";
    }
    return baseKey;
  };
  var View = class _View {
    static closestView(el) {
      const liveViewEl = el.closest(PHX_VIEW_SELECTOR);
      return liveViewEl ? dom_default.private(liveViewEl, "view") : null;
    }
    constructor(el, liveSocket2, parentView, flash = null, liveReferer = null) {
      this.rendered = null;
      this.isDead = false;
      this.liveSocket = liveSocket2;
      this.flash = flash;
      this.parent = parentView;
      this.root = parentView ? parentView.root : this;
      this.el = el;
      const boundView = dom_default.private(this.el, "view");
      if (boundView !== void 0 && boundView.isDead !== true) {
        this.logError(
          "view.duplicate-binding",
          `The DOM element for this view has already been bound to a view.

        An element can only ever be associated with a single view!
        Please ensure that you are not trying to initialize multiple LiveSockets on the same page.
        This could happen if you're accidentally trying to render your root layout more than once.
        Ensure that the template set on the LiveView is different than the root layout.
      `,
          { view: boundView },
          { attribution: "app" }
        );
        throw new Error("Cannot bind multiple views to the same DOM element.");
      }
      dom_default.putPrivate(this.el, "view", this);
      this.id = this.el.id;
      this.el.setAttribute(PHX_ROOT_ID, this.root.id);
      this.ref = 0;
      this.lastAckRef = null;
      this.childJoins = 0;
      this.loaderTimer = null;
      this.disconnectedTimer = null;
      this.pendingDiffs = [];
      this.pendingForms = /* @__PURE__ */ new Set();
      this.activeUploaders = /* @__PURE__ */ new Set();
      this.redirect = false;
      this.href = null;
      this.joinCount = this.parent ? this.parent.joinCount - 1 : 0;
      this.joinAttempts = 0;
      this.joinPending = true;
      this.destroyed = false;
      this.joinCallback = function(onDone) {
        onDone && onDone();
      };
      this.stopCallback = function() {
      };
      this.pendingJoinOps = [];
      this.viewHooks = {};
      this.formSubmits = [];
      this.children = this.parent ? null : {};
      this.root.children[this.id] = {};
      this.formsForRecovery = {};
      this.channel = this.liveSocket.channel(`lv:${this.id}`, () => {
        const url = this.href && this.expandURL(this.href);
        return {
          redirect: this.redirect ? url : void 0,
          url: this.redirect ? void 0 : url || void 0,
          params: this.connectParams(liveReferer),
          session: this.getSession(),
          static: this.getStatic(),
          flash: this.flash ?? void 0,
          sticky: this.el.hasAttribute(PHX_STICKY)
        };
      });
      this.portalElementIds = /* @__PURE__ */ new Set();
    }
    setHref(href) {
      this.href = href;
    }
    setRedirect(href) {
      this.redirect = true;
      this.href = href;
    }
    isMain() {
      return this.el.hasAttribute(PHX_MAIN);
    }
    connectParams(liveReferer) {
      const params = this.liveSocket.params(this.el);
      const manifest = dom_default.all(document, `[${this.binding(PHX_TRACK_STATIC)}]`).map(
        (node) => "src" in node && node.src || "href" in node && node.href
      ).filter((url) => typeof url === "string");
      if (manifest.length > 0) {
        params["_track_static"] = manifest;
      }
      params["_mounts"] = this.joinCount;
      params["_mount_attempts"] = this.joinAttempts;
      params["_live_referer"] = liveReferer ?? void 0;
      this.joinAttempts++;
      return params;
    }
    isConnected() {
      return this.channel.canPush();
    }
    getSession() {
      return this.el.getAttribute(PHX_SESSION);
    }
    getStatic() {
      const val = this.el.getAttribute(PHX_STATIC);
      return val === "" ? null : val;
    }
    destroy(callback = function() {
    }) {
      js_default.dropFocus(this);
      this.destroyAllChildren();
      this.destroyPortalElements();
      this.destroyed = true;
      this.activeUploaders.forEach((uploader) => uploader.cancel());
      this.activeUploaders.clear();
      dom_default.deletePrivate(this.el, "view");
      delete this.root.children[this.id];
      if (this.parent) {
        delete this.root.children[this.parent.id][this.id];
      }
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      const onFinished = () => {
        callback();
        for (const id in this.viewHooks) {
          this.destroyHook(this.viewHooks[id]);
        }
      };
      dom_default.markPhxChildDestroyed(this.el);
      this.log(
        "destroyed",
        () => ["the child has been removed from the parent"],
        {
          code: "view.child-destroyed"
        }
      );
      this.channel.leave().receive("ok", onFinished).receive("error", onFinished).receive("timeout", onFinished);
    }
    setContainerClasses(...classes) {
      this.el.classList.remove(
        PHX_CONNECTED_CLASS,
        PHX_LOADING_CLASS,
        PHX_ERROR_CLASS,
        PHX_CLIENT_ERROR_CLASS,
        PHX_SERVER_ERROR_CLASS
      );
      this.el.classList.add(...classes);
    }
    showLoader(timeout) {
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      if (timeout) {
        this.loaderTimer = setTimeout(() => this.showLoader(), timeout);
      } else {
        for (const id in this.viewHooks) {
          this.viewHooks[id].__disconnected();
        }
        this.setContainerClasses(PHX_LOADING_CLASS);
      }
    }
    execAll(binding) {
      dom_default.all(
        this.el,
        `[${binding}]`,
        (el) => this.liveSocket.execJS(el, el.getAttribute(binding))
      );
    }
    hideLoader() {
      this.loaderTimer != null && clearTimeout(this.loaderTimer);
      this.disconnectedTimer != null && clearTimeout(this.disconnectedTimer);
      this.disconnectedTimer = null;
      this.setContainerClasses(PHX_CONNECTED_CLASS);
      this.execAll(this.binding("connected"));
    }
    triggerReconnected() {
      for (const id in this.viewHooks) {
        this.viewHooks[id].__reconnected();
      }
    }
    log(kind, msgCallback, diagnostic) {
      this.liveSocket.log(this, kind, msgCallback, diagnostic);
    }
    logError(code, message, metadata, context = { attribution: "unknown" }) {
      logError(code, message, metadata, {
        viewId: this.id ?? this.el.id,
        ...context
      });
    }
    transition(time, onStart, onDone = function() {
    }) {
      this.liveSocket.transition(time, onStart, onDone);
    }
    // calls the callback with the view and target element for the given phxTarget
    // targets can be:
    //  * an element itself, then it is simply passed to liveSocket.owner;
    //  * a CID (Component ID), then we first search the component's element in the DOM
    //  * a selector, then we search the selector in the DOM and call the callback
    //    for each element found with the corresponding owner view
    withinTargets(phxTarget, callback, dom = document) {
      if (phxTarget instanceof HTMLElement || phxTarget instanceof SVGElement) {
        return this.liveSocket.owner(
          phxTarget,
          (view) => callback(view, phxTarget)
        );
      }
      if (isCid(phxTarget)) {
        const target = dom_default.findComponent(this.id, phxTarget, dom);
        if (!target) {
          this.logError(
            "event.missing-component-target",
            `no component found matching phx-target of ${phxTarget}`,
            { target: phxTarget }
          );
        } else {
          callback(
            this,
            typeof phxTarget === "number" ? phxTarget : parseInt(phxTarget)
          );
        }
      } else {
        const targets = Array.from(dom.querySelectorAll(phxTarget));
        if (targets.length === 0) {
          this.logError(
            "event.missing-selector-target",
            `nothing found matching the phx-target selector "${phxTarget}"`,
            { target: phxTarget },
            { attribution: "app" }
          );
        }
        targets.forEach(
          (target) => this.liveSocket.owner(target, (view) => callback(view, target))
        );
      }
    }
    applyDiff(type, rawDiff, callback) {
      const clonedDiff = clone(rawDiff);
      this.log(type, () => ["received diff", clonedDiff], {
        code: `view.diff-${type}`,
        metadata: () => ({ diff: clonedDiff })
      });
      const { diff, reply, events, title } = Rendered.extract(rawDiff);
      const ev = events.reduce(
        (acc, args) => {
          if (args.length === 3 && args[2] == true) {
            acc.pre.push(args.slice(0, -1));
          } else {
            acc.post.push(args);
          }
          return acc;
        },
        { pre: [], post: [] }
      );
      this.liveSocket.dispatchEvents(ev.pre);
      const update = () => {
        callback({ diff, reply, events: ev.post });
        if (typeof title === "string" || type == "mount" && this.isMain()) {
          window.requestAnimationFrame(() => dom_default.putTitle(title));
        }
      };
      if ("onDocumentPatch" in this.liveSocket.domCallbacks) {
        this.liveSocket.triggerDOM("onDocumentPatch", [update]);
      } else {
        update();
      }
    }
    onJoin(resp) {
      const { rendered, container, liveview_version, pid } = resp;
      if (container) {
        const [tag, attrs] = container;
        this.el = dom_default.replaceRootContainer(this.el, tag, attrs);
        dom_default.putPrivate(this.el, "view", this);
      }
      this.childJoins = 0;
      this.joinPending = true;
      this.flash = null;
      if (this.root === this) {
        this.formsForRecovery = this.getFormsForRecovery();
      }
      if (this.isMain() && window.history.state === null) {
        browser_default.pushState("replace", {
          type: "patch",
          id: this.id,
          position: this.liveSocket.currentHistoryPosition
        });
      }
      if (liveview_version !== this.liveSocket.version()) {
        console.warn(
          `LiveView asset version mismatch. JavaScript version ${this.liveSocket.version()} vs. server ${liveview_version}. To avoid issues, please ensure that your assets use the same version as the server.`
        );
      }
      if (pid) {
        this.el.setAttribute(PHX_LV_PID, pid);
      }
      browser_default.dropLocal(
        this.liveSocket.localStorage,
        window.location.pathname,
        CONSECUTIVE_RELOADS
      );
      this.applyDiff("mount", rendered, ({ diff, events }) => {
        this.rendered = new Rendered(
          this.id,
          diff,
          () => this.liveSocket.RenderingBuffer
        );
        const [html, streams] = this.renderContainer(null, "join");
        this.dropPendingRefs();
        this.joinCount++;
        this.joinAttempts = 0;
        this.maybeRecoverForms(html, () => {
          this.onJoinComplete(resp, html, streams, events);
        });
      });
    }
    dropPendingRefs() {
      dom_default.all(document, `[${PHX_REF_SRC}="${this.refSrc()}"]`, (el) => {
        el.removeAttribute(PHX_REF_LOADING);
        el.removeAttribute(PHX_REF_SRC);
        el.removeAttribute(PHX_REF_LOCK);
      });
    }
    onJoinComplete({ live_patch }, html, streams, events) {
      if (this.joinCount > 1 || this.parent && !this.parent.isJoinPending()) {
        return this.applyJoinPatch(live_patch, html, streams, events);
      }
      const newChildren = dom_default.findPhxChildrenInFragment(html, this.id).filter(
        (toEl) => {
          const fromEl = toEl.id && this.el.querySelector(`[id="${toEl.id}"]`);
          const phxStatic = fromEl && fromEl.getAttribute(PHX_STATIC);
          if (phxStatic) {
            toEl.setAttribute(PHX_STATIC, phxStatic);
          }
          if (fromEl) {
            fromEl.setAttribute(PHX_ROOT_ID, this.root.id);
          }
          return this.joinChild(toEl);
        }
      );
      if (newChildren.length === 0) {
        if (this.parent) {
          this.root.pendingJoinOps.push([
            this,
            () => this.applyJoinPatch(live_patch, html, streams, events)
          ]);
          this.parent.ackJoin(this);
        } else {
          this.onAllChildJoinsComplete();
          this.applyJoinPatch(live_patch, html, streams, events);
        }
      } else {
        this.root.pendingJoinOps.push([
          this,
          () => this.applyJoinPatch(live_patch, html, streams, events)
        ]);
      }
    }
    attachTrueDocEl() {
      const el = dom_default.byId(this.id);
      if (!el) {
        throw new Error("unable to find root element for view");
      }
      this.el = el;
      dom_default.putPrivate(this.el, "view", this);
      this.el.setAttribute(PHX_ROOT_ID, this.root.id);
    }
    // this is invoked for dead and live views, so we must filter by
    // by owner to ensure we aren't duplicating hooks across disconnect
    // and connected states. This also handles cases where hooks exist
    // in a root layout with a LV in the body
    execNewMounted(parent = document) {
      let phxViewportTop = this.binding(PHX_VIEWPORT_TOP);
      let phxViewportBottom = this.binding(PHX_VIEWPORT_BOTTOM);
      this.all(
        parent,
        `[${phxViewportTop}], [${phxViewportBottom}]`,
        (hookEl) => {
          dom_default.maintainPrivateHooks(
            hookEl,
            hookEl,
            phxViewportTop,
            phxViewportBottom
          );
          this.maybeAddNewHook(hookEl);
        }
      );
      this.all(
        parent,
        `[${this.binding(PHX_HOOK)}], [data-phx-${PHX_HOOK}]`,
        (hookEl) => {
          this.maybeAddNewHook(hookEl);
        }
      );
      this.all(parent, `[${this.binding(PHX_MOUNTED)}]`, (el) => {
        this.maybeMounted(el);
      });
    }
    all(parent, selector, callback) {
      dom_default.all(parent, selector, (el) => {
        if (this.ownsElement(el)) {
          callback(el);
        }
      });
    }
    applyJoinPatch(live_patch, html, streams, events) {
      if (this.joinCount > 1) {
        if (this.pendingJoinOps.length) {
          this.pendingJoinOps.forEach((cb) => typeof cb === "function" && cb());
          this.pendingJoinOps = [];
        }
      }
      this.attachTrueDocEl();
      const patch = new DOMPatch(this, this.el, html, streams, null);
      patch.markPrunableContentForRemoval();
      this.performPatch(patch, false, true);
      this.joinNewChildren();
      this.execNewMounted();
      this.joinPending = false;
      this.liveSocket.dispatchEvents(events);
      this.applyPendingUpdates();
      if (live_patch) {
        const { kind, to } = live_patch;
        this.liveSocket.historyPatch(to, kind);
      }
      this.hideLoader();
      if (this.joinCount > 1) {
        this.triggerReconnected();
      }
      this.stopCallback();
    }
    triggerBeforeUpdateHook(fromEl, toEl) {
      this.liveSocket.triggerDOM("onBeforeElUpdated", [fromEl, toEl]);
      const hook = this.getHook(fromEl);
      const isIgnored = hook && dom_default.isIgnored(fromEl, this.binding(PHX_UPDATE));
      if (hook && !fromEl.isEqualNode(toEl) && !(isIgnored && isEqualObj(fromEl.dataset, toEl.dataset))) {
        hook.__beforeUpdate(toEl);
        return hook;
      }
    }
    maybeMounted(el) {
      const phxMounted = el.getAttribute(this.binding(PHX_MOUNTED));
      const hasBeenInvoked = phxMounted && dom_default.private(el, "mounted");
      if (phxMounted && !hasBeenInvoked) {
        this.liveSocket.execJS(el, phxMounted);
        dom_default.putPrivate(el, "mounted", true);
      }
    }
    maybeAddNewHook(el) {
      const newHook = this.addHook(el);
      if (newHook) {
        newHook.__mounted();
      }
    }
    performPatch(patch, pruneCids, isJoinPatch = false) {
      const removedEls = [];
      let phxChildrenAdded = false;
      const updatedHookIds = /* @__PURE__ */ new Set();
      const newHookIds = /* @__PURE__ */ new Set();
      this.liveSocket.triggerDOM("onPatchStart", [patch.targetContainer]);
      patch.afterAdded((el) => {
        this.liveSocket.triggerDOM("onNodeAdded", [el]);
        const phxViewportTop = this.binding(PHX_VIEWPORT_TOP);
        const phxViewportBottom = this.binding(PHX_VIEWPORT_BOTTOM);
        dom_default.maintainPrivateHooks(el, el, phxViewportTop, phxViewportBottom);
        this.maybeAddNewHook(el);
        if (el.getAttribute) {
          this.maybeMounted(el);
        }
      });
      patch.afterPhxChildAdded((el) => {
        if (dom_default.isPhxSticky(el)) {
          this.liveSocket.joinRootViews();
        } else {
          phxChildrenAdded = true;
        }
      });
      const hookAttr = this.binding(PHX_HOOK);
      const privateHookAttr = `data-phx-${PHX_HOOK}`;
      patch.beforeUpdated((fromEl, toEl) => {
        const hook = this.triggerBeforeUpdateHook(fromEl, toEl);
        if (hook) {
          if (fromEl.hasAttribute(hookAttr) && fromEl.getAttribute(hookAttr) !== toEl.getAttribute(hookAttr)) {
            this.destroyHook(hook);
            if (toEl.getAttribute(hookAttr)) {
              newHookIds.add(toEl.id);
            }
          } else {
            updatedHookIds.add(fromEl.id);
          }
        } else if (toEl.id && toEl.getAttribute && !this.getHook(fromEl)) {
          if (toEl.getAttribute(hookAttr) || toEl.getAttribute(privateHookAttr)) {
            newHookIds.add(toEl.id);
          }
        }
        js_default.onBeforeElUpdated(fromEl, toEl);
      });
      patch.afterUpdated((el) => {
        if (updatedHookIds.has(el.id)) {
          const hook = this.getHook(el);
          hook && hook.__updated();
        } else if (newHookIds.has(el.id)) {
          this.maybeAddNewHook(el);
        }
      });
      patch.afterDiscarded((el) => {
        if (el.nodeType === Node.ELEMENT_NODE) {
          removedEls.push(el);
        }
      });
      patch.afterTransitionsDiscarded(
        (els) => this.afterElementsRemoved(els, pruneCids)
      );
      patch.perform(isJoinPatch);
      this.afterElementsRemoved(removedEls, pruneCids);
      this.liveSocket.triggerDOM("onPatchEnd", [patch.targetContainer]);
      return phxChildrenAdded;
    }
    afterElementsRemoved(elements, pruneCids) {
      const destroyedCIDs = [];
      elements.forEach((parent) => {
        const components = dom_default.all(
          parent,
          `[${PHX_VIEW_REF}="${this.id}"][${PHX_COMPONENT}]`
        );
        const hooks = dom_default.all(
          parent,
          `[${this.binding(PHX_HOOK)}], [data-phx-hook]`
        );
        components.concat(parent).forEach((el) => {
          const cid = this.componentID(el);
          if (isCid(cid) && destroyedCIDs.indexOf(cid) === -1 && el.getAttribute(PHX_VIEW_REF) === this.id) {
            destroyedCIDs.push(cid);
          }
        });
        hooks.concat(parent).forEach((hookEl) => {
          const hook = this.getHook(hookEl);
          hook && this.destroyHook(hook);
        });
      });
      if (pruneCids) {
        this.maybePushComponentsDestroyed(destroyedCIDs);
      }
    }
    joinNewChildren() {
      dom_default.findPhxChildren(document, this.id).forEach((el) => this.joinChild(el));
    }
    maybeRecoverForms(html, callback) {
      const phxChange = this.binding("change");
      const oldForms = this.root.formsForRecovery;
      const template = document.createElement("template");
      template.innerHTML = html;
      if (!template.content.firstElementChild) {
        return callback();
      }
      dom_default.all(template.content, `[${PHX_PORTAL}]`).forEach((portalTemplate) => {
        if (!(portalTemplate instanceof HTMLTemplateElement)) {
          return;
        }
        template.content.firstElementChild?.appendChild(
          portalTemplate.content.firstElementChild
        );
      });
      const rootEl = template.content.firstElementChild;
      rootEl.id = this.id;
      rootEl.setAttribute(PHX_ROOT_ID, this.root.id);
      rootEl.setAttribute(PHX_SESSION, this.getSession());
      rootEl.setAttribute(PHX_STATIC, this.getStatic() ?? "");
      this.parent && rootEl.setAttribute(PHX_PARENT_ID, this.parent.id);
      dom_default.putPrivate(rootEl, "view", this);
      const formsToRecover = (
        // we go over all forms in the new DOM; because this is only the HTML for the current
        // view, we can be sure that all forms are owned by this view:
        dom_default.all(template.content, "form").filter((newForm) => newForm.id && oldForms[newForm.id]).filter((newForm) => !this.pendingForms.has(newForm.id)).filter(
          (newForm) => oldForms[newForm.id].getAttribute(phxChange) === newForm.getAttribute(phxChange)
        ).map((newForm) => {
          return [oldForms[newForm.id], newForm];
        })
      );
      if (formsToRecover.length === 0) {
        return callback();
      }
      let formsRecovered = 0;
      formsToRecover.forEach(([oldForm, newForm]) => {
        this.pendingForms.add(newForm.id);
        this.pushFormRecovery(
          oldForm,
          newForm,
          template.content.firstElementChild,
          () => {
            this.pendingForms.delete(newForm.id);
            formsRecovered++;
            if (formsRecovered === formsToRecover.length) {
              callback();
            }
          }
        );
      });
    }
    getChildById(id) {
      return this.root.children[this.id][id];
    }
    getDescendentByEl(el) {
      if (el.id === this.id) {
        return this;
      } else {
        return this.children && this.children[el.getAttribute(PHX_PARENT_ID)]?.[el.id];
      }
    }
    destroyDescendent(id) {
      for (const parentId in this.root.children) {
        for (const childId in this.root.children[parentId]) {
          if (childId === id) {
            return this.root.children[parentId][childId].destroy();
          }
        }
      }
    }
    joinChild(el) {
      const child = this.getChildById(el.id);
      if (!child) {
        const view = new _View(el, this.liveSocket, this);
        this.root.children[this.id][view.id] = view;
        view.join();
        this.childJoins++;
        return true;
      }
    }
    isJoinPending() {
      return this.joinPending;
    }
    ackJoin(_child) {
      this.childJoins--;
      if (this.childJoins === 0) {
        if (this.parent) {
          this.parent.ackJoin(this);
        } else {
          this.onAllChildJoinsComplete();
        }
      }
    }
    onAllChildJoinsComplete() {
      this.pendingForms.clear();
      this.formsForRecovery = {};
      this.joinCallback(() => {
        this.pendingJoinOps.forEach(([view, op]) => {
          if (!view.isDestroyed()) {
            op();
          }
        });
        this.pendingJoinOps = [];
      });
    }
    update(diff, events, isPending = false) {
      if (this.isJoinPending() || this.liveSocket.hasPendingLink() && this.root.isMain()) {
        if (!isPending) {
          this.pendingDiffs.push({ diff, events, joinCount: this.joinCount });
        }
        return false;
      }
      this.rendered.mergeDiff(diff);
      let phxChildrenAdded = false;
      if (this.rendered.isComponentOnlyDiff(diff)) {
        this.liveSocket.time("component patch complete", () => {
          const parentCids = dom_default.findExistingParentCIDs(
            this.id,
            this.rendered.componentCIDs(diff)
          );
          parentCids.forEach((parentCID) => {
            if (this.componentPatch(
              this.rendered.getComponent(diff, parentCID),
              parentCID
            )) {
              phxChildrenAdded = true;
            }
          });
        });
      } else if (!isEmpty(diff)) {
        this.liveSocket.time("full patch complete", () => {
          const [html, streams] = this.renderContainer(diff, "update");
          const patch = new DOMPatch(this, this.el, html, streams, null);
          phxChildrenAdded = this.performPatch(patch, true);
        });
      }
      this.liveSocket.dispatchEvents(events);
      if (phxChildrenAdded) {
        this.joinNewChildren();
      }
      return true;
    }
    renderContainer(diff, kind) {
      return this.liveSocket.time(`toString diff (${kind})`, () => {
        const tag = this.el.tagName;
        const cids = diff ? this.rendered.componentCIDs(diff) : null;
        const { buffer: html, streams } = this.rendered.toString(cids);
        return [`<${tag}>${html}</${tag}>`, streams];
      });
    }
    componentPatch(diff, cid) {
      if (isEmpty(diff))
        return false;
      const { buffer: html, streams } = this.rendered.componentToString(cid);
      const patch = new DOMPatch(this, this.el, html, streams, cid);
      const childrenAdded = this.performPatch(patch, true);
      return childrenAdded;
    }
    getHook(el) {
      return this.viewHooks[ViewHook.elementID(el)];
    }
    addHook(el) {
      const hookElId = ViewHook.elementID(el);
      if (el.getAttribute && !this.ownsElement(el)) {
        return;
      }
      if (hookElId && !this.viewHooks[hookElId]) {
        if (ViewHook.deadHook(el)) {
          return;
        }
        const hook = dom_default.getCustomElHook(el) || this.logError(
          "hook.custom-element-missing-hook",
          `no hook found for custom element: ${el.id}`,
          { el },
          { attribution: "app" }
        );
        this.viewHooks[hookElId] = hook;
        hook.__attachView(this);
        return hook;
      } else if (hookElId || !el.getAttribute) {
        return;
      } else {
        const hookName = el.getAttribute(`data-phx-${PHX_HOOK}`) || el.getAttribute(this.binding(PHX_HOOK));
        if (!hookName) {
          return;
        }
        const hookDefinition = this.liveSocket.getHookDefinition(hookName);
        if (hookDefinition) {
          if (!el.id) {
            this.logError(
              "hook.missing-id",
              `no DOM ID for hook "${hookName}". Hooks require a unique ID on each element.`,
              { el, hookName },
              { attribution: "app" }
            );
            return;
          }
          let hookInstance;
          try {
            if (typeof hookDefinition === "function" && hookDefinition.prototype instanceof ViewHook) {
              hookInstance = new hookDefinition(this, el);
            } else if (typeof hookDefinition === "object" && hookDefinition !== null) {
              hookInstance = new ViewHook(this, el, hookDefinition);
            } else {
              this.logError(
                "hook.invalid-definition",
                `Invalid hook definition for "${hookName}". Expected a class extending ViewHook or an object definition.`,
                { el, hookName },
                { attribution: "app" }
              );
              return;
            }
          } catch (e) {
            const errorMessage = e instanceof Error ? e.message : String(e);
            this.logError(
              "hook.creation-failed",
              `Failed to create hook "${hookName}": ${errorMessage}`,
              { el, hookName, error: e },
              { attribution: "app" }
            );
            return;
          }
          this.viewHooks[ViewHook.elementID(hookInstance.el)] = hookInstance;
          return hookInstance;
        } else if (hookName !== null) {
          this.logError(
            "hook.unknown",
            `unknown hook found for "${hookName}"`,
            {
              el,
              hookName
            },
            { attribution: "app" }
          );
        }
      }
    }
    destroyHook(hook) {
      const hookId = ViewHook.elementID(hook.el);
      hook.__destroyed();
      hook.__cleanup__();
      delete this.viewHooks[hookId];
    }
    applyPendingUpdates() {
      this.pendingDiffs = this.pendingDiffs.filter(
        ({ diff, events, joinCount }) => {
          if (joinCount !== this.joinCount) {
            this.log(
              "update",
              () => ["discarded diff from previous join", diff],
              {
                code: "view.stale-diff-discarded",
                metadata: () => ({ joinCount, currentJoinCount: this.joinCount })
              }
            );
            return false;
          }
          return !this.update(diff, events, true);
        }
      );
      this.eachChild((child) => child.applyPendingUpdates());
    }
    eachChild(callback) {
      const children = this.root.children[this.id] || {};
      for (const id in children) {
        callback(this.getChildById(id));
      }
    }
    onChannel(event, cb) {
      this.liveSocket.onChannel(this.channel, event, (resp) => {
        if (this.isJoinPending() && !["redirect", "live_redirect"].includes(event)) {
          if (this.joinCount > 1) {
            this.pendingJoinOps.push(() => cb(resp));
          } else {
            this.root.pendingJoinOps.push([this, () => cb(resp)]);
          }
        } else {
          this.liveSocket.requestDOMUpdate(() => cb(resp));
        }
      });
    }
    bindChannel() {
      this.liveSocket.onChannel(this.channel, "diff", (rawDiff) => {
        this.liveSocket.requestDOMUpdate(() => {
          this.applyDiff(
            "update",
            rawDiff,
            ({ diff, events }) => this.update(diff, events)
          );
        });
      });
      this.onChannel(
        "redirect",
        ({ to, flash }) => this.onRedirect({ to, flash })
      );
      this.onChannel("live_patch", (redir) => this.onLivePatch(redir));
      this.onChannel("live_redirect", (redir) => this.onLiveRedirect(redir));
      this.channel.onError((reason) => this.onError(reason));
      this.channel.onClose((reason) => this.onClose(reason));
    }
    destroyAllChildren() {
      this.eachChild((child) => child.destroy());
    }
    onLiveRedirect(redir) {
      const { to, kind, flash } = redir;
      const url = this.expandURL(to);
      const e = new CustomEvent("phx:server-navigate", {
        detail: { to, kind, flash }
      });
      this.liveSocket.historyRedirect(e, url, kind, flash);
    }
    onLivePatch(redir) {
      const { to, kind } = redir;
      this.href = this.expandURL(to);
      this.liveSocket.historyPatch(to, kind);
    }
    expandURL(to) {
      return to.startsWith("/") ? `${window.location.protocol}//${window.location.host}${to}` : to;
    }
    onRedirect({
      to,
      flash,
      reloadToken
    }) {
      this.liveSocket.redirect(to, flash ?? null, reloadToken ?? null);
    }
    isDestroyed() {
      return this.destroyed;
    }
    joinDead() {
      this.isDead = true;
    }
    join(callback) {
      this.showLoader(this.liveSocket.loaderTimeout);
      this.bindChannel();
      if (this.isMain()) {
        this.stopCallback = this.liveSocket.withPageLoading({
          to: this.href,
          kind: "initial"
        });
      }
      this.joinCallback = (onDone) => {
        onDone = onDone || function() {
        };
        callback ? callback(this.joinCount, onDone) : onDone();
      };
      this.wrapPush(() => this.channel.join(), {
        ok: (resp) => this.liveSocket.requestDOMUpdate(() => this.onJoin(resp)),
        error: (error) => this.onJoinError(error),
        timeout: () => this.onJoinError({ reason: "timeout" })
      });
    }
    onJoinError(resp) {
      if (resp.events) {
        this.liveSocket.dispatchEvents(resp.events);
      }
      if (resp.reason === "reload") {
        this.log(
          "error",
          () => [
            `failed mount with ${resp.status}. Falling back to page reload`,
            resp
          ],
          {
            code: "view.mount-reload",
            level: "error",
            metadata: () => ({ status: resp.status }),
            context: { attribution: "app" }
          }
        );
        this.onRedirect({
          to: this.liveSocket.main.href,
          reloadToken: resp.token
        });
        return;
      } else if (resp.reason === "unauthorized" || resp.reason === "stale") {
        this.log(
          "error",
          () => [
            "unauthorized live_redirect. Falling back to page request",
            resp
          ],
          {
            code: "view.unauthorized-live-redirect",
            level: "error",
            metadata: () => ({ reason: resp.reason }),
            context: { attribution: "app" }
          }
        );
        this.onRedirect({ to: this.liveSocket.main.href, flash: this.flash });
        return;
      }
      if (resp.redirect || resp.live_redirect) {
        this.joinPending = false;
        this.channel.leave();
      }
      if (resp.redirect) {
        return this.onRedirect(resp.redirect);
      }
      if (resp.live_redirect) {
        return this.onLiveRedirect(resp.live_redirect);
      }
      const timedOut = resp.reason === "timeout";
      const attribution = timedOut || resp.source === "transport" ? "network" : "app";
      this.log(
        "error",
        () => [timedOut ? "join timed out" : "unable to join", resp],
        {
          code: timedOut ? "view.join-timeout" : "view.join-failed",
          level: "error",
          metadata: () => timedOut ? { error: resp } : { response: resp },
          context: { attribution }
        }
      );
      if (this.isMain()) {
        this.displayError(
          [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
          { unstructuredError: resp, errorKind: "server" }
        );
        if (this.liveSocket.isConnected()) {
          this.liveSocket.reloadWithJitter(this);
        }
      } else {
        if (this.joinAttempts >= MAX_CHILD_JOIN_ATTEMPTS) {
          this.root.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: resp, errorKind: "server" }
          );
          this.log(
            "error",
            () => [
              `giving up trying to mount after ${MAX_CHILD_JOIN_ATTEMPTS} tries`,
              resp
            ],
            {
              code: "view.mount-attempts-exhausted",
              level: "error",
              metadata: () => ({
                attempts: MAX_CHILD_JOIN_ATTEMPTS,
                response: resp
              })
            }
          );
          this.destroy();
          return;
        }
        const trueChildEl = dom_default.byId(this.el.id);
        if (trueChildEl) {
          dom_default.mergeAttrs(trueChildEl, this.el);
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: resp, errorKind: "server" }
          );
          this.el = trueChildEl;
        } else {
          this.destroy();
        }
      }
    }
    onClose(reason) {
      if (this.isDestroyed()) {
        return;
      }
      if (this.isMain() && this.liveSocket.hasPendingLink() && reason !== "leave") {
        return this.liveSocket.reloadWithJitter(this);
      }
      this.destroyAllChildren();
      this.liveSocket.dropActiveElement(this);
      if (this.liveSocket.isUnloaded()) {
        this.showLoader(BEFORE_UNLOAD_LOADER_TIMEOUT);
      }
    }
    onError(reason) {
      this.onClose(reason);
      if (this.liveSocket.isConnected()) {
        this.log("error", () => ["view crashed", reason], {
          code: "view.crashed",
          level: "error",
          metadata: () => ({ reason }),
          context: { attribution: "app" }
        });
      }
      if (!this.liveSocket.isUnloaded()) {
        if (this.liveSocket.isConnected()) {
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_SERVER_ERROR_CLASS],
            { unstructuredError: reason, errorKind: "server" }
          );
        } else {
          this.displayError(
            [PHX_LOADING_CLASS, PHX_ERROR_CLASS, PHX_CLIENT_ERROR_CLASS],
            { unstructuredError: reason, errorKind: "client" }
          );
        }
      }
    }
    displayError(classes, details = {}) {
      if (this.isMain()) {
        dom_default.dispatchEvent(window, "phx:page-loading-start", {
          detail: { to: this.href, kind: "error", ...details }
        });
      }
      this.showLoader();
      this.setContainerClasses(...classes);
      this.delayedDisconnected();
    }
    delayedDisconnected() {
      if (this.disconnectedTimer != null) {
        return;
      }
      this.disconnectedTimer = setTimeout(() => {
        this.disconnectedTimer = null;
        this.execAll(this.binding("disconnected"));
      }, this.liveSocket.disconnectedTimeout);
    }
    wrapPush(callerPush, receives) {
      const latency = this.liveSocket.getLatencySim();
      const withLatency = latency ? (cb) => setTimeout(() => !this.isDestroyed() && cb(), latency) : (cb) => !this.isDestroyed() && cb();
      withLatency(() => {
        callerPush().receive(
          "ok",
          (resp) => withLatency(() => receives.ok && receives.ok(resp))
        ).receive(
          "error",
          (reason) => withLatency(() => receives.error && receives.error(reason))
        ).receive(
          "timeout",
          () => withLatency(() => receives.timeout && receives.timeout())
        );
      });
    }
    pushWithReply(refGenerator, event, payload) {
      if (!this.isConnected()) {
        return Promise.resolve({
          type: "error",
          error: "no connection",
          context: { attribution: "network" }
        });
      }
      const [ref, [el], opts] = refGenerator ? refGenerator({ payload }) : [null, [], {}];
      const oldJoinCount = this.joinCount;
      let onLoadingDone = function() {
      };
      if (opts.page_loading) {
        onLoadingDone = this.liveSocket.withPageLoading({
          kind: "element",
          target: el
        });
      }
      if (typeof payload.cid !== "number") {
        delete payload.cid;
      }
      return new Promise((resolve) => {
        this.wrapPush(() => this.channel.push(event, payload, PUSH_TIMEOUT), {
          ok: (resp) => {
            if (ref !== null) {
              this.lastAckRef = ref;
            }
            const finish = (hookReply) => {
              if (resp.redirect) {
                this.onRedirect(resp.redirect);
              }
              if (resp.live_patch) {
                this.onLivePatch(resp.live_patch);
              }
              if (resp.live_redirect) {
                this.onLiveRedirect(resp.live_redirect);
              }
              onLoadingDone();
              resolve({ type: "ok", resp, reply: hookReply, ref });
            };
            if (resp.diff) {
              this.liveSocket.requestDOMUpdate(() => {
                this.applyDiff("update", resp.diff, ({ diff, reply, events }) => {
                  if (ref !== null) {
                    this.undoRefs(ref, payload.event);
                  }
                  this.update(diff, events);
                  finish(reply);
                });
              });
            } else {
              if (ref !== null) {
                this.undoRefs(ref, payload.event);
              }
              finish(null);
            }
          },
          error: (reason) => {
            onLoadingDone();
            resolve({
              type: "error",
              error: `failed with reason: ${JSON.stringify(reason)}`,
              context: {
                attribution: "app"
              }
            });
          },
          timeout: () => {
            onLoadingDone();
            resolve({
              type: "error",
              error: "push timeout",
              context: { attribution: "network" }
            });
            if (this.joinCount === oldJoinCount) {
              this.liveSocket.reloadWithJitter(this, () => {
                this.log(
                  "timeout",
                  () => [
                    "received timeout while communicating with server. Falling back to hard refresh for recovery"
                  ],
                  {
                    code: "view.push-timeout-recovery",
                    level: "error",
                    context: { attribution: "network" }
                  }
                );
              });
            }
          }
        });
      });
    }
    undoRefs(ref, phxEvent, onlyEls) {
      if (!this.isConnected()) {
        return;
      }
      const selector = `[${PHX_REF_SRC}="${this.refSrc()}"]`;
      if (onlyEls) {
        onlyEls = new Set(onlyEls);
        dom_default.all(document, selector, (parent) => {
          if (onlyEls && !onlyEls.has(parent)) {
            return;
          }
          dom_default.all(
            parent,
            selector,
            (child) => this.undoElRef(child, ref, phxEvent)
          );
          this.undoElRef(parent, ref, phxEvent);
        });
      } else {
        dom_default.all(document, selector, (el) => this.undoElRef(el, ref, phxEvent));
      }
    }
    undoElRef(el, ref, phxEvent) {
      const elRef = new ElementRef(el);
      elRef.maybeUndo(ref, phxEvent, (clonedTree) => {
        const patch = new DOMPatch(this, el, clonedTree, /* @__PURE__ */ new Set(), null, {
          undoRef: ref
        });
        const phxChildrenAdded = this.performPatch(patch, true);
        dom_default.all(
          el,
          `[${PHX_REF_SRC}="${this.refSrc()}"]`,
          (child) => this.undoElRef(child, ref, phxEvent)
        );
        if (phxChildrenAdded) {
          this.joinNewChildren();
        }
      });
    }
    refSrc() {
      return this.el.id;
    }
    putRef(elements, phxEvent, eventType, opts = {}) {
      const newRef = this.ref++;
      const disableWith = this.binding(PHX_DISABLE_WITH);
      if (opts.loading) {
        const loadingEls = dom_default.all(document, opts.loading).map((el) => {
          return { el, lock: true, loading: true };
        });
        elements = elements.concat(loadingEls);
      }
      for (const { el, lock, loading } of elements) {
        if (!lock && !loading) {
          throw new Error("putRef requires lock or loading");
        }
        el.setAttribute(PHX_REF_SRC, this.refSrc());
        if (loading) {
          el.setAttribute(PHX_REF_LOADING, newRef.toString());
        }
        if (lock) {
          el.setAttribute(PHX_REF_LOCK, newRef.toString());
        }
        if (!loading || opts.submitter && !(el === opts.submitter || el === opts.form)) {
          continue;
        }
        const lockCompletePromise = new Promise((resolve) => {
          el.addEventListener(`phx:undo-lock:${newRef}`, () => resolve(detail), {
            once: true
          });
        });
        const loadingCompletePromise = new Promise((resolve) => {
          el.addEventListener(
            `phx:undo-loading:${newRef}`,
            () => resolve(detail),
            { once: true }
          );
        });
        el.classList.add(`phx-${eventType}-loading`);
        const disableText = el.getAttribute(disableWith);
        if (disableText !== null) {
          if (!el.getAttribute(PHX_DISABLE_WITH_RESTORE)) {
            el.setAttribute(PHX_DISABLE_WITH_RESTORE, el.textContent || "");
          }
          if (disableText !== "") {
            el.textContent = disableText;
          }
          el.setAttribute(
            PHX_DISABLED,
            el.getAttribute(PHX_DISABLED) || ("disabled" in el ? String(el.disabled) : "")
          );
          el.setAttribute("disabled", "");
        }
        const detail = {
          event: phxEvent,
          eventType,
          ref: newRef,
          isLoading: loading,
          isLocked: lock,
          lockElements: elements.filter(({ lock: lock2 }) => lock2).map(({ el: el2 }) => el2),
          loadingElements: elements.filter(({ loading: loading2 }) => loading2).map(({ el: el2 }) => el2),
          unlock: (els) => {
            els = Array.isArray(els) ? els : [els];
            this.undoRefs(newRef, phxEvent, els);
          },
          lockComplete: lockCompletePromise,
          loadingComplete: loadingCompletePromise,
          lock: (lockEl) => {
            return new Promise((resolve) => {
              if (this.isAcked(newRef)) {
                return resolve(detail);
              }
              lockEl.setAttribute(PHX_REF_LOCK, newRef);
              lockEl.setAttribute(PHX_REF_SRC, this.refSrc());
              lockEl.addEventListener(
                `phx:undo-lock:${newRef}`,
                () => resolve(detail),
                { once: true }
              );
            });
          }
        };
        if (opts.payload) {
          detail["payload"] = opts.payload;
        }
        if (opts.target) {
          detail["target"] = opts.target;
        }
        if (opts.originalEvent) {
          detail["originalEvent"] = opts.originalEvent;
        }
        el.dispatchEvent(
          new CustomEvent("phx:push", {
            detail,
            bubbles: true,
            cancelable: false
          })
        );
        if (phxEvent) {
          el.dispatchEvent(
            new CustomEvent(`phx:push:${phxEvent}`, {
              detail,
              bubbles: true,
              cancelable: false
            })
          );
        }
      }
      return [newRef, elements.map(({ el }) => el), opts];
    }
    isAcked(ref) {
      return this.lastAckRef !== null && this.lastAckRef >= ref;
    }
    componentID(el) {
      const cid = el.getAttribute && el.getAttribute(PHX_COMPONENT);
      return cid ? parseInt(cid) : null;
    }
    targetComponentID(target, targetCtx, opts = {}) {
      if (isCid(targetCtx)) {
        return targetCtx;
      }
      const cidOrSelector = opts.target || target.getAttribute(this.binding("target"));
      if (isCid(cidOrSelector)) {
        return typeof cidOrSelector === "number" ? cidOrSelector : parseInt(cidOrSelector);
      } else if (targetCtx && (cidOrSelector !== null || opts.target)) {
        return this.closestComponentID(targetCtx);
      } else {
        return null;
      }
    }
    closestComponentID(targetCtx) {
      if (isCid(targetCtx)) {
        return targetCtx;
      } else if (targetCtx) {
        return maybe(
          // We either use the closest data-phx-component binding, or -
          // in case of portals - continue with the portal source.
          // This is necessary if teleporting an element outside of its LiveComponent.
          targetCtx.closest(`[${PHX_COMPONENT}],[${PHX_TELEPORTED_SRC}]`),
          (el) => {
            if (el.hasAttribute(PHX_COMPONENT)) {
              return this.ownsElement(el) && this.componentID(el);
            }
            if (el.hasAttribute(PHX_TELEPORTED_SRC)) {
              const portalParent = dom_default.byId(el.getAttribute(PHX_TELEPORTED_SRC));
              return this.closestComponentID(portalParent);
            }
          }
        );
      } else {
        return null;
      }
    }
    pushHookEvent(el, targetCtx, event, payload) {
      if (!this.isConnected()) {
        this.log(
          "hook",
          () => [
            "unable to push hook event. LiveView not connected",
            { event, payload }
          ],
          {
            code: "hook.push-disconnected",
            metadata: () => ({ event, payload }),
            context: { attribution: "network" }
          }
        );
        return Promise.reject(
          new Error("unable to push hook event. LiveView not connected")
        );
      }
      const refGenerator = () => this.putRef([{ el, loading: true, lock: true }], event, "hook", {
        payload,
        target: targetCtx
      });
      return this.pushWithReply(refGenerator, "event", {
        type: "hook",
        event,
        value: payload,
        cid: this.closestComponentID(targetCtx)
      }).then((result) => {
        if (result.type === "error") {
          throw new Error("Failed to push hook event: " + result.error);
        }
        return { reply: result.reply, ref: result.ref };
      });
    }
    extractMeta(el, meta, value) {
      const prefix = this.binding("value-");
      for (let i = 0; i < el.attributes.length; i++) {
        if (!meta) {
          meta = {};
        }
        const name = el.attributes[i].name;
        if (name.startsWith(prefix)) {
          meta[name.replace(prefix, "")] = el.getAttribute(name);
        }
      }
      if (el.value !== void 0 && !(el instanceof HTMLFormElement)) {
        if (!meta) {
          meta = {};
        }
        meta.value = el.value;
        if (el.tagName === "INPUT" && CHECKABLE_INPUTS.indexOf(el.type) >= 0 && !el.checked) {
          delete meta.value;
        }
      }
      if (value) {
        if (!meta) {
          meta = {};
        }
        for (const key in value) {
          meta[key] = value[key];
        }
      }
      return meta;
    }
    serializeForm(form, opts = {}, onlyNames = []) {
      const { submitter } = opts;
      let injectedElement;
      if (submitter && submitter.name) {
        const input = document.createElement("input");
        input.type = "hidden";
        const formId = submitter.getAttribute("form");
        if (formId) {
          input.setAttribute("form", formId);
        }
        input.name = submitter.name;
        input.value = submitter.value;
        submitter.parentElement.insertBefore(input, submitter);
        injectedElement = input;
      }
      const formData = new FormData(form);
      const toRemove = [];
      formData.forEach((val, key, _index) => {
        if (val instanceof File) {
          toRemove.push(key);
        }
      });
      toRemove.forEach((key) => formData.delete(key));
      const params = new URLSearchParams();
      const { inputsUnused, onlyHiddenInputs } = Array.from(form.elements).reduce(
        (acc, input) => {
          if (!dom_default.isFormAssociated(input)) {
            return acc;
          }
          const { inputsUnused: inputsUnused2, onlyHiddenInputs: onlyHiddenInputs2 } = acc;
          const key = input.name;
          if (!key) {
            return acc;
          }
          if (inputsUnused2[key] === void 0) {
            inputsUnused2[key] = true;
          }
          if (onlyHiddenInputs2[key] === void 0) {
            onlyHiddenInputs2[key] = true;
          }
          const inputSkipUnusedField = input.hasAttribute(
            this.binding(PHX_NO_UNUSED_FIELD)
          );
          const isUsed = dom_default.private(input, PHX_HAS_FOCUSED) || dom_default.private(input, PHX_HAS_SUBMITTED) || inputSkipUnusedField;
          const isHidden = input.type === "hidden";
          inputsUnused2[key] = inputsUnused2[key] && !isUsed;
          onlyHiddenInputs2[key] = onlyHiddenInputs2[key] && isHidden;
          return acc;
        },
        { inputsUnused: {}, onlyHiddenInputs: {} }
      );
      const formSkipUnusedFields = form.hasAttribute(
        this.binding(PHX_NO_UNUSED_FIELD)
      );
      for (const [key, val] of formData.entries()) {
        if (onlyNames.length === 0 || onlyNames.indexOf(key) >= 0) {
          const isUnused = inputsUnused[key];
          const hidden = onlyHiddenInputs[key];
          const skipUnusedCheck = formSkipUnusedFields;
          if (!skipUnusedCheck && isUnused && !(submitter && submitter.name == key) && !hidden) {
            params.append(prependFormDataKey(key, "_unused_"), "");
          }
          if (typeof val === "string") {
            params.append(key, val);
          }
        }
      }
      if (submitter && injectedElement) {
        submitter.parentElement.removeChild(injectedElement);
      }
      return params.toString();
    }
    pushEvent(type, el, targetCtx, phxEvent, meta, opts = {}, onReply) {
      this.pushWithReply(
        (maybePayload) => this.putRef([{ el, loading: true, lock: true }], phxEvent, type, {
          ...opts,
          payload: maybePayload?.payload
        }),
        "event",
        {
          type,
          event: phxEvent,
          value: this.extractMeta(el, meta, opts.value),
          cid: this.targetComponentID(el, targetCtx, opts)
        }
      ).then((result) => {
        if (result.type === "ok") {
          onReply && onReply(result.reply);
        } else {
          this.logError(
            "event.push-failed",
            "Failed to push event",
            {
              error: result.error,
              type,
              phxEvent,
              el
            },
            result.context
          );
        }
      });
    }
    pushFileProgress(fileEl, entryRef, progress, onReply = function() {
    }) {
      this.liveSocket.withinOwners(fileEl.form, (view, targetCtx) => {
        view.pushWithReply(null, "progress", {
          event: fileEl.getAttribute(view.binding(PHX_PROGRESS)),
          ref: fileEl.getAttribute(PHX_UPLOAD_REF),
          entry_ref: entryRef,
          progress,
          cid: view.targetComponentID(fileEl.form, targetCtx)
        }).then((result) => {
          if (result.type === "ok") {
            onReply();
          } else {
            view.logError(
              "upload.progress-push-failed",
              "Failed to push file progress",
              { error: result.error, fileEl, entryRef, progress },
              result.context
            );
          }
        });
      });
    }
    pushInput(inputEl, targetCtx, forceCid, phxEvent, opts, callback) {
      if (!inputEl.form) {
        throw new Error("form events require the input to be inside a form");
      }
      let uploads;
      const cid = isCid(forceCid) ? forceCid : this.targetComponentID(inputEl.form, targetCtx, opts);
      const refGenerator = (maybePayload) => {
        return this.putRef(
          [
            { el: inputEl, loading: true, lock: true },
            { el: inputEl.form, loading: true, lock: true }
          ],
          phxEvent,
          "change",
          { ...opts, payload: maybePayload?.payload }
        );
      };
      let formData;
      const meta = this.extractMeta(inputEl.form, {}, opts.value);
      const serializeOpts = {};
      if (inputEl instanceof HTMLButtonElement) {
        serializeOpts.submitter = inputEl;
      }
      if (inputEl.getAttribute(this.binding("change"))) {
        formData = this.serializeForm(inputEl.form, serializeOpts, [
          inputEl.name
        ]);
      } else {
        formData = this.serializeForm(inputEl.form, serializeOpts);
      }
      if (dom_default.isUploadInput(inputEl) && inputEl.files && inputEl.files.length > 0) {
        LiveUploader.trackFiles(inputEl, Array.from(inputEl.files));
      }
      uploads = LiveUploader.serializeUploads(inputEl);
      const event = {
        type: "form",
        event: phxEvent,
        value: formData,
        meta: {
          // no target was implicitly sent as "undefined" in LV <= 1.0.5, therefore
          // we have to keep it. In 1.0.6 we switched from passing meta as URL encoded data
          // to passing it directly in the event, but the JSON encode would drop keys with
          // undefined values.
          _target: opts._target || "undefined",
          ...meta
        },
        uploads,
        cid
      };
      this.pushWithReply(refGenerator, "event", event).then((result) => {
        if (result.type === "ok") {
          if (dom_default.isUploadInput(inputEl) && dom_default.isAutoUpload(inputEl)) {
            ElementRef.onUnlock(inputEl, () => {
              if (LiveUploader.filesAwaitingPreflight(inputEl).length > 0) {
                const [ref, _els] = refGenerator();
                this.undoRefs(ref, phxEvent, [inputEl.form]);
                this.uploadFiles(
                  inputEl.form,
                  phxEvent,
                  targetCtx,
                  (_uploads) => {
                    callback && callback(result.resp);
                    this.triggerAwaitingSubmit(inputEl.form);
                    this.undoRefs(ref, phxEvent);
                  },
                  // the change event itself was delivered, so there is no
                  // submit to report; only release the form
                  () => this.undoRefs(ref, phxEvent)
                );
              }
            });
          } else {
            callback && callback(result.resp);
          }
        } else {
          this.logError(
            "event.input-push-failed",
            "Failed to push input event",
            {
              error: result.error,
              inputEl,
              phxEvent
            },
            result.context
          );
        }
      });
    }
    triggerAwaitingSubmit(formEl) {
      const awaitingSubmit = this.getScheduledSubmit(formEl);
      if (awaitingSubmit) {
        const [_el, _ref, _opts, callback] = awaitingSubmit;
        this.cancelSubmit(formEl);
        callback();
      }
    }
    getScheduledSubmit(formEl) {
      return this.formSubmits.find(
        ([el, _ref, _opts, _callback]) => el.isSameNode(formEl)
      );
    }
    scheduleSubmit(formEl, ref, opts, callback, phxEvent) {
      if (this.getScheduledSubmit(formEl)) {
        return true;
      }
      this.formSubmits.push([formEl, ref, opts, callback, phxEvent]);
    }
    // a submit is intentionally dropped when its uploads cannot complete, but
    // without a signal the click looks like a no-op to the developer, so we
    // emit a debug diagnostic naming the uploads and why the submit was not sent
    logBlockedSubmit(formEl, phxEvent, reason, inputs, scheduled = false) {
      const uploads = inputs.map((input) => input.name);
      const what = scheduled ? `scheduled ${phxEvent}` : phxEvent;
      this.log(
        "upload",
        () => [
          `${what} not sent (${reason}): ${uploads.join(", ")}`,
          { reason, uploads }
        ],
        {
          code: "upload.submit-blocked",
          metadata: () => ({
            event: phxEvent,
            reason,
            uploads,
            scheduled,
            formEl
          })
        }
      );
    }
    // cancels the submit scheduled while uploads were in progress, if any, and
    // undoes its refs. `blocked` says why the submit is dropped for good; it is
    // omitted when the scheduled submit is dequeued to be sent (see
    // triggerAwaitingSubmit)
    cancelSubmit(formEl, blocked) {
      this.formSubmits = this.formSubmits.filter(
        ([el, ref, _opts, _callback, phxEvent]) => {
          if (el.isSameNode(formEl)) {
            if (blocked) {
              this.logBlockedSubmit(
                formEl,
                phxEvent,
                blocked.reason,
                blocked.inputs,
                true
              );
            }
            this.undoRefs(ref, phxEvent);
            return false;
          } else {
            return true;
          }
        }
      );
    }
    disableForm(formEl, phxEvent, opts = {}) {
      const filterIgnored = (el) => {
        const userIgnored = closestPhxBinding(
          el,
          `${this.binding(PHX_UPDATE)}=ignore`,
          el.form
        );
        return !(userIgnored || closestPhxBinding(el, "data-phx-update=ignore", el.form));
      };
      const filterDisables = (el) => {
        return el.hasAttribute(this.binding(PHX_DISABLE_WITH));
      };
      const filterButton = (el) => el.tagName == "BUTTON";
      const filterInput = (el) => ["INPUT", "TEXTAREA"].includes(el.tagName);
      const formElements = Array.from(formEl.elements);
      const disables = formElements.filter(filterDisables);
      const buttons = formElements.filter(filterButton).filter(filterIgnored);
      const inputs = formElements.filter(filterInput).filter(filterIgnored);
      buttons.forEach((button) => {
        button.setAttribute(PHX_DISABLED, button.disabled.toString());
        button.disabled = true;
      });
      inputs.forEach((input) => {
        input.setAttribute(PHX_READONLY, input.readOnly.toString());
        input.readOnly = true;
        if (input instanceof HTMLInputElement && input.files) {
          input.setAttribute(PHX_DISABLED, input.disabled.toString());
          input.disabled = true;
        }
      });
      const formEls = disables.concat(buttons).concat(inputs).map((el) => {
        return { el, loading: true, lock: true };
      });
      const els = [
        { el: formEl, loading: true, lock: false },
        ...formEls
      ].reverse();
      return this.putRef(els, phxEvent, "submit", opts);
    }
    pushFormSubmit(formEl, targetCtx, phxEvent, submitter, opts, onReply) {
      const refGenerator = (maybePayload) => this.disableForm(formEl, phxEvent, {
        ...opts,
        form: formEl,
        payload: maybePayload?.payload,
        submitter
      });
      dom_default.putPrivate(formEl, "submitter", submitter);
      const cid = this.targetComponentID(formEl, targetCtx);
      const inputsWithErrors = LiveUploader.inputsWithUploadErrors(formEl);
      if (inputsWithErrors.length > 0) {
        this.logBlockedSubmit(formEl, phxEvent, "entry-errors", inputsWithErrors);
        return this.cancelSubmit(formEl);
      } else if (LiveUploader.hasUploadsInProgress(formEl)) {
        const [ref, _els] = refGenerator();
        const push = () => this.pushFormSubmit(
          formEl,
          targetCtx,
          phxEvent,
          submitter,
          opts,
          onReply
        );
        return this.scheduleSubmit(formEl, ref, opts, push, phxEvent);
      } else if (LiveUploader.inputsAwaitingPreflight(formEl).length > 0) {
        const [ref, els] = refGenerator();
        const proxyRefGen = () => [ref, els, opts];
        const onBlocked = (reason, inputs) => {
          this.logBlockedSubmit(formEl, phxEvent, reason, inputs);
          this.undoRefs(ref, phxEvent);
        };
        this.uploadFiles(
          formEl,
          phxEvent,
          targetCtx,
          (_uploads) => {
            const awaitingPreflight = LiveUploader.inputsAwaitingPreflight(formEl);
            if (awaitingPreflight.length > 0) {
              return onBlocked("awaiting-preflight", awaitingPreflight);
            }
            const meta = this.extractMeta(formEl, {}, opts.value);
            const formData = this.serializeForm(formEl, { submitter });
            this.pushWithReply(proxyRefGen, "event", {
              type: "form",
              event: phxEvent,
              value: formData,
              meta,
              cid
            }).then((result) => {
              if (result.type === "ok") {
                onReply(result.resp);
              } else {
                this.logError(
                  "event.submit-push-failed",
                  "Failed to push form submit",
                  {
                    error: result.error,
                    phxEvent,
                    formEl
                  },
                  result.context
                );
              }
            });
          },
          onBlocked
        );
      } else if (!(formEl.hasAttribute(PHX_REF_SRC) && formEl.classList.contains("phx-submit-loading"))) {
        const meta = this.extractMeta(formEl, {}, opts.value);
        const formData = this.serializeForm(formEl, { submitter });
        this.pushWithReply(refGenerator, "event", {
          type: "form",
          event: phxEvent,
          value: formData,
          meta,
          cid
        }).then((result) => {
          if (result.type === "ok") {
            onReply(result.resp);
          } else {
            this.logError(
              "event.submit-push-failed",
              "Failed to push form submit",
              {
                error: result.error,
                phxEvent,
                formEl
              },
              result.context
            );
          }
        });
      }
    }
    // onComplete is called once the uploads of every input are done; onBlocked
    // is called instead when a preflight was rejected or failed, or an upload
    // failed, with the reason and the inputs involved. The caller is responsible
    // for releasing the form. When inputs are blocked for different reasons, the
    // first reason seen is reported with its inputs; the others have their own
    // logs.
    uploadFiles(formEl, phxEvent, targetCtx, onComplete, onBlocked) {
      const joinCountAtUpload = this.joinCount;
      const inputEls = LiveUploader.activeFileInputs(formEl);
      let numFileInputsInProgress = inputEls.length;
      const blocked = [];
      const inputBlocked = (reason, inputEl) => {
        const group = blocked.find((b) => b.reason === reason);
        if (group) {
          group.inputs.push(inputEl);
        } else {
          blocked.push({ reason, inputs: [inputEl] });
        }
      };
      const inputDone = () => {
        numFileInputsInProgress--;
        if (numFileInputsInProgress > 0) {
          return;
        }
        if (blocked.length > 0) {
          this.cancelSubmit(formEl, blocked[0]);
          onBlocked(blocked[0].reason, blocked[0].inputs);
        } else {
          onComplete();
        }
      };
      inputEls.forEach((inputEl) => {
        const uploader = new LiveUploader(inputEl, this, () => {
          this.activeUploaders.delete(uploader);
          if (uploader.entries().some((entry) => entry.isErrored())) {
            inputBlocked("upload-failed", inputEl);
          }
          inputDone();
        });
        this.activeUploaders.add(uploader);
        const entries = uploader.entries().map((entry) => entry.toPreflightPayload());
        if (entries.length === 0) {
          this.activeUploaders.delete(uploader);
          inputDone();
          return;
        }
        const payload = {
          ref: inputEl.getAttribute(PHX_UPLOAD_REF),
          entries,
          cid: this.targetComponentID(inputEl.form, targetCtx)
        };
        this.log("upload", () => ["sending preflight request", payload], {
          code: "upload.preflight-request",
          metadata: () => ({ payload })
        });
        this.pushWithReply(null, "allow_upload", payload).then((result) => {
          if (result.type === "ok") {
            this.log("upload", () => ["got preflight response", result.resp], {
              code: "upload.preflight-response",
              metadata: () => ({ response: result.resp })
            });
            uploader.entries().forEach((entry) => {
              if (result.resp.entries && !result.resp.entries[entry.ref]) {
                this.handleFailedEntryPreflight(
                  entry.ref,
                  "failed preflight",
                  uploader
                );
              }
            });
            if (result.resp.error || Object.keys(result.resp.entries).length === 0) {
              const errors = result.resp.error || [];
              errors.map(([entry_ref, reason]) => {
                this.handleFailedEntryPreflight(entry_ref, reason, uploader);
              });
              this.activeUploaders.delete(uploader);
              inputBlocked("preflight-rejected", inputEl);
              inputDone();
            } else {
              const onError = (callback) => {
                this.channel.onError(() => {
                  if (this.joinCount === joinCountAtUpload) {
                    callback();
                  }
                });
              };
              uploader.initAdapterUpload(result.resp, onError, this.liveSocket);
            }
          } else {
            uploader.cancel();
            this.activeUploaders.delete(uploader);
            this.logError(
              "upload.push-failed",
              "Failed to push upload",
              {
                error: result.error,
                phxEvent,
                formEl
              },
              result.context
            );
            inputBlocked("preflight-failed", inputEl);
            inputDone();
          }
        });
      });
    }
    handleFailedEntryPreflight(uploadRef, reason, uploader) {
      if (uploader.isAutoUpload()) {
        const entry = uploader.entries().find((entry2) => entry2.ref === uploadRef.toString());
        if (entry) {
          entry.cancel();
        }
      } else {
        uploader.entries().map((entry) => entry.cancel());
      }
      this.log("upload", () => [`error for entry ${uploadRef}`, reason], {
        code: "upload.preflight-rejected",
        metadata: () => ({ uploadRef, reason })
      });
    }
    dispatchUploads(targetCtx, name, filesOrBlobs) {
      const targetElement = this.targetCtxElement(targetCtx) || this.el;
      const inputs = dom_default.findUploadInputs(targetElement).filter(
        (el) => el.name === name
      );
      if (inputs.length === 0) {
        this.logError(
          "upload.input-not-found",
          `no live file inputs found matching the name "${name}"`,
          { name },
          { attribution: "app" }
        );
      } else if (inputs.length > 1) {
        this.logError(
          "upload.duplicate-input",
          `duplicate live file inputs found matching the name "${name}"`,
          { name, inputs },
          { attribution: "app" }
        );
      } else {
        dom_default.dispatchEvent(inputs[0], PHX_TRACK_UPLOADS, {
          detail: { files: filesOrBlobs }
        });
      }
    }
    targetCtxElement(targetCtx) {
      if (isCid(targetCtx)) {
        const target = dom_default.findComponent(this.id, targetCtx);
        return target;
      } else if (targetCtx) {
        return targetCtx;
      } else {
        return null;
      }
    }
    pushFormRecovery(oldForm, newForm, templateDom, callback) {
      const phxChange = this.binding("change");
      const phxTarget = newForm.getAttribute(this.binding("target")) || newForm;
      const phxEvent = newForm.getAttribute(this.binding(PHX_AUTO_RECOVER)) || newForm.getAttribute(this.binding("change"));
      const inputs = Array.from(oldForm.elements).filter(
        (el) => dom_default.isFormAssociated(el) && el.name && !el.hasAttribute(phxChange)
      );
      if (inputs.length === 0) {
        callback();
        return;
      }
      inputs.forEach(
        (input2) => input2.hasAttribute(PHX_UPLOAD_REF) && LiveUploader.clearFiles(input2)
      );
      const input = inputs.find((el) => el.type !== "hidden") || inputs[0];
      let pending = 0;
      this.withinTargets(
        phxTarget,
        (targetView, targetCtx) => {
          const cid = this.targetComponentID(newForm, targetCtx);
          pending++;
          let e = new CustomEvent("phx:form-recovery", {
            detail: { sourceElement: oldForm }
          });
          js_default.exec(e, "change", phxEvent, this, input, [
            "push",
            {
              _target: input.name,
              targetView,
              targetCtx,
              newCid: cid,
              callback: () => {
                pending--;
                if (pending === 0) {
                  callback();
                }
              }
            }
          ]);
        },
        templateDom
      );
    }
    pushLinkPatch(e, href, targetEl, callback) {
      const linkRef = this.liveSocket.setPendingLink(href);
      const loading = e.isTrusted && e.type !== "popstate";
      const refGen = targetEl ? () => this.putRef(
        [{ el: targetEl, loading, lock: true }],
        null,
        "click"
      ) : null;
      const fallback = () => this.liveSocket.redirect(window.location.href, null, null);
      const url = href.startsWith("/") ? `${location.protocol}//${location.host}${href}` : href;
      this.pushWithReply(refGen, "live_patch", { url }).then((result) => {
        if (result.type === "ok") {
          this.liveSocket.requestDOMUpdate(() => {
            if (result.resp.link_redirect) {
              this.liveSocket.replaceMain(href, null, callback, linkRef);
            } else if (result.resp.redirect) {
              return;
            } else {
              if (this.liveSocket.commitPendingLink(linkRef)) {
                this.href = href;
              }
              this.applyPendingUpdates();
              callback && callback(linkRef);
            }
          });
        } else {
          fallback();
        }
      });
    }
    getFormsForRecovery() {
      if (this.joinCount === 0) {
        return {};
      }
      const phxChange = this.binding("change");
      return dom_default.all(
        document,
        `#${CSS.escape(this.id)} form[${phxChange}], [${PHX_TELEPORTED_REF}="${CSS.escape(this.id)}"] form[${phxChange}]`
      ).filter((form) => form instanceof HTMLFormElement).filter((form) => form.id).filter((form) => form.elements.length > 0).filter(
        (form) => form.getAttribute(this.binding(PHX_AUTO_RECOVER)) !== "ignore"
      ).map((form) => {
        const clonedForm = form.cloneNode(true);
        index_default(clonedForm, form, {
          onBeforeElUpdated: (fromEl, toEl) => {
            dom_default.copyPrivates(fromEl, toEl);
            if (fromEl.getAttribute("form") === form.id && fromEl.parentNode) {
              fromEl.parentNode.removeChild(fromEl);
              return false;
            }
            return true;
          }
        });
        const externalElements = document.querySelectorAll(
          `[form="${CSS.escape(form.id)}"]`
        );
        Array.from(externalElements).forEach((el) => {
          const clonedEl = el.cloneNode(true);
          index_default(clonedEl, el);
          dom_default.copyPrivates(clonedEl, el);
          clonedEl.removeAttribute("form");
          clonedForm.appendChild(clonedEl);
        });
        return clonedForm;
      }).reduce((acc, form) => {
        acc[form.id] = form;
        return acc;
      }, {});
    }
    maybePushComponentsDestroyed(destroyedCIDs) {
      let willDestroyCIDs = destroyedCIDs.filter((cid) => {
        return dom_default.findComponent(this.id, cid) === null;
      });
      const onError = (result, cids) => {
        if (!this.isDestroyed()) {
          this.logError(
            "component.destroy-push-failed",
            "Failed to push components destroyed",
            { error: result.error, cids },
            result.context
          );
        }
      };
      if (willDestroyCIDs.length > 0) {
        willDestroyCIDs.forEach((cid) => this.rendered.resetRender(cid));
        this.pushWithReply(null, "cids_will_destroy", {
          cids: willDestroyCIDs
        }).then((result) => {
          if (result.type === "ok") {
            this.liveSocket.requestDOMUpdate(() => {
              let completelyDestroyCIDs = willDestroyCIDs.filter((cid) => {
                return dom_default.findComponent(this.id, cid) === null;
              });
              if (completelyDestroyCIDs.length > 0) {
                this.pushWithReply(null, "cids_destroyed", {
                  cids: completelyDestroyCIDs
                }).then((result2) => {
                  if (result2.type === "ok") {
                    this.rendered.pruneCIDs(result2.resp.cids);
                  } else {
                    onError(result2, completelyDestroyCIDs);
                  }
                });
              }
            });
          } else {
            onError(result, willDestroyCIDs);
          }
        });
      }
    }
    ownsElement(el) {
      let parentViewEl = dom_default.closestViewEl(el);
      return el.getAttribute(PHX_PARENT_ID) === this.id || parentViewEl && parentViewEl.id === this.id || !parentViewEl && this.isDead;
    }
    submitForm(form, targetCtx, phxEvent, submitter, opts = {}) {
      dom_default.putPrivate(form, PHX_HAS_SUBMITTED, true);
      const inputs = Array.from(form.elements);
      inputs.forEach((input) => dom_default.putPrivate(input, PHX_HAS_SUBMITTED, true));
      this.liveSocket.blurActiveElement();
      this.pushFormSubmit(form, targetCtx, phxEvent, submitter, opts, () => {
        this.liveSocket.restorePreviouslyActiveFocus();
      });
    }
    binding(kind) {
      return this.liveSocket.binding(kind);
    }
    // phx-portal
    pushPortalElementId(id) {
      this.portalElementIds.add(id);
    }
    dropPortalElementId(id) {
      this.portalElementIds.delete(id);
    }
    destroyPortalElements() {
      if (!this.liveSocket.unloaded) {
        this.portalElementIds.forEach((id) => {
          const el = document.getElementById(id);
          if (el) {
            el.remove();
          }
        });
      }
    }
  };
  var BUFFERS = Object.freeze({ RenderingBuffer, ReportingBuffer });
  var LiveSocket = class {
    /**
     * Creates a new LiveSocket instance.
     */
    constructor(url, phxSocket, opts = {}) {
      this.unloaded = false;
      this.buffers = BUFFERS;
      if (!phxSocket || phxSocket.constructor.name === "Object") {
        throw new Error(`
      a phoenix Socket must be provided as the second argument to the LiveSocket constructor. For example:

          import {Socket} from "phoenix"
          import {LiveSocket} from "phoenix_live_view"
          let liveSocket = new LiveSocket("/live", Socket, {...})
      `);
      }
      this.socket = new phxSocket(url, opts);
      this.bindingPrefix = opts.bindingPrefix || BINDING_PREFIX;
      this.params = closure2(opts.params || {});
      this.viewLogger = opts.viewLogger;
      this.metadataCallbacks = opts.metadata || {};
      this.defaults = Object.assign(clone(DEFAULTS), opts.defaults || {});
      this.prevActive = null;
      this.silenced = false;
      this.main = null;
      this.outgoingMainEl = null;
      this.clickStartedAtTarget = null;
      this.linkRef = 1;
      this.roots = {};
      this.href = window.location.href;
      this.pendingLink = null;
      this.currentLocation = clone(window.location);
      this.hooks = opts.hooks || {};
      this.uploaders = opts.uploaders || {};
      this.RenderingBuffer = RenderingBuffer;
      this.loaderTimeout = opts.loaderTimeout || LOADER_TIMEOUT;
      this.disconnectedTimeout = opts.disconnectedTimeout || DISCONNECTED_TIMEOUT;
      this.reloadWithJitterTimer = null;
      this.maxReloads = opts.maxReloads || MAX_RELOADS;
      this.reloadJitterMin = opts.reloadJitterMin || RELOAD_JITTER_MIN;
      this.reloadJitterMax = opts.reloadJitterMax || RELOAD_JITTER_MAX;
      this.failsafeJitter = opts.failsafeJitter || FAILSAFE_JITTER;
      this.localStorage = opts.localStorage || window.localStorage;
      this.sessionStorage = opts.sessionStorage || window.sessionStorage;
      this.boundTopLevelEvents = false;
      this.boundEventNames = /* @__PURE__ */ new Set();
      this.blockPhxChangeWhileComposing = opts.blockPhxChangeWhileComposing || false;
      this.cascadePhxRemoveOnNavigation = opts.cascadePhxRemoveOnNavigation ?? true;
      this.serverCloseRef = null;
      this.domCallbacks = Object.assign(
        {
          jsQuerySelectorAll: null,
          onPatchStart: closure2(),
          onPatchEnd: closure2(),
          onNodeAdded: closure2(),
          onBeforeElUpdated: closure2()
        },
        opts.dom || {}
      );
      this.transitions = new TransitionSet();
      this.currentHistoryPosition = parseInt(this.sessionStorage.getItem(PHX_LV_HISTORY_POSITION) || "0") || 0;
      window.addEventListener("pagehide", (_e) => {
        this.unloaded = true;
      });
      this.socket.onOpen(() => {
        if (this.isUnloaded()) {
          window.location.reload();
        }
      });
    }
    // public
    /**
     * Returns the version of the LiveView client.
     */
    version() {
      return "1.2.13";
    }
    /**
     * Returns true if profiling is enabled. See {@link enableProfiling} and {@link disableProfiling}.
     */
    isProfileEnabled() {
      return this.sessionStorage.getItem(PHX_LV_PROFILE) === "true";
    }
    /**
     * Installs a rendered buffer: what the renderer writes rendered HTML through.
     *
     * A buffer can observe or annotate the output — for example to mark which
     * HEEx function components re-rendered, for a debugging overlay. See
     * {@link RenderingBuffer} for the protocol a buffer implements.
     *
     * It applies to views that are already mounted as well as to views that join
     * later, and nothing is re-rendered to install it: it sees each part of the
     * page the next time a patch renders that part, so a buffer that annotates
     * the output leaves whatever is already in the DOM untouched until then.
     *
     *     const previous = liveSocket.attachDebugBuffer(MyBuffer)
     *
     * @param bufferClass - a class extending {@link RenderingBuffer}.
     * @returns The class installed until now, to restore it with.
     *
     * @internal
     */
    attachDebugBuffer(bufferClass) {
      const current = this.RenderingBuffer;
      this.RenderingBuffer = bufferClass;
      return current;
    }
    /**
     * Returns true if debugging is enabled. See {@link enableDebug} and {@link disableDebug}.
     */
    isDebugEnabled() {
      return this.sessionStorage.getItem(PHX_LV_DEBUG) === "true";
    }
    /**
     * Returns true if debugging is disabled. See {@link enableDebug} and {@link disableDebug}.
     */
    isDebugDisabled() {
      return this.sessionStorage.getItem(PHX_LV_DEBUG) === "false";
    }
    /**
     * Enables debugging.
     *
     * When debugging is enabled, the LiveView client will log debug information to the console.
     * See [Debugging client events](https://phoenix-live-view.hexdocs.pm/js-interop.html#debugging-client-events) for more information.
     */
    enableDebug() {
      this.sessionStorage.setItem(PHX_LV_DEBUG, "true");
    }
    /**
     * Enables profiling.
     *
     * When profiling is enabled, the LiveView client will log profiling information to the console.
     */
    enableProfiling() {
      this.sessionStorage.setItem(PHX_LV_PROFILE, "true");
    }
    /**
     * Disables debugging.
     */
    disableDebug() {
      this.sessionStorage.setItem(PHX_LV_DEBUG, "false");
    }
    /**
     * Disables profiling.
     */
    disableProfiling() {
      this.sessionStorage.removeItem(PHX_LV_PROFILE);
    }
    /**
     * Enables latency simulation.
     *
     * When latency simulation is enabled, the LiveView client will add a delay to requests and responses from the server.
     * See [Simulating Latency](https://phoenix-live-view.hexdocs.pm/js-interop.html#simulating-latency) for more information.
     */
    enableLatencySim(upperBoundMs) {
      this.enableDebug();
      console.log(
        "latency simulator enabled for the duration of this browser session. Call disableLatencySim() to disable"
      );
      this.sessionStorage.setItem(PHX_LV_LATENCY_SIM, upperBoundMs.toString());
    }
    /**
     * Disables latency simulation.
     */
    disableLatencySim() {
      this.sessionStorage.removeItem(PHX_LV_LATENCY_SIM);
    }
    /**
     * Returns the current latency simulation upper bound.
     */
    getLatencySim() {
      const str = this.sessionStorage.getItem(PHX_LV_LATENCY_SIM);
      return str ? parseInt(str) : null;
    }
    /**
     * Returns the Phoenix Socket instance.
     */
    getSocket() {
      return this.socket;
    }
    /**
     * Connects to the LiveView server.
     */
    connect() {
      const host = window.location.hostname.toLowerCase();
      if ((host === "localhost" || host.endsWith(".localhost")) && !this.isDebugDisabled()) {
        this.enableDebug();
      }
      const doConnect = () => {
        this.resetReloadStatus();
        if (this.joinRootViews()) {
          this.bindTopLevelEvents();
          this.socket.connect();
        } else if (this.main) {
          this.socket.connect();
        } else {
          this.bindTopLevelEvents({ dead: true });
        }
        this.joinDeadView();
      };
      if (["complete", "loaded", "interactive"].indexOf(document.readyState) >= 0) {
        doConnect();
      } else {
        document.addEventListener("DOMContentLoaded", () => doConnect());
      }
    }
    /**
     * Disconnects from the LiveView server.
     */
    disconnect(callback) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      if (this.serverCloseRef) {
        this.socket.off([this.serverCloseRef]);
        this.serverCloseRef = null;
      }
      this.socket.disconnect(callback);
    }
    /**
     * Can be used to replace the transport used by the underlying Phoenix Socket.
     */
    replaceTransport(transport) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      this.socket.replaceTransport(transport);
      this.connect();
    }
    /**
     * Executes an encoded JS command, targeting the given element.
     *
     * See [`Phoenix.LiveView.JS`](https://phoenix-live-view.hexdocs.pm/Phoenix.LiveView.JS.html) for more information.
     */
    execJS(el, encodedJS, eventType = null) {
      const e = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
      this.owner(el, (view) => js_default.exec(e, eventType, encodedJS, view, el));
    }
    /**
     * Returns an object with methods to manipulate the DOM and execute JavaScript.
     * The applied changes integrate with server DOM patching.
     *
     * See [JavaScript interoperability](https://phoenix-live-view.hexdocs.pm/js-interop.html) for more information.
     */
    js() {
      return js_commands_default(this, "js");
    }
    // private
    /** @internal */
    unload() {
      if (this.unloaded) {
        return;
      }
      if (this.main && this.isConnected()) {
        this.log(this.main, "socket", () => ["disconnect for page nav"], {
          code: "socket.page-navigation-disconnect"
        });
      }
      this.unloaded = true;
      this.destroyAllViews();
      this.disconnect();
    }
    /** @internal */
    triggerDOM(kind, args) {
      this.domCallbacks[kind](...args);
    }
    /** @internal */
    time(name, func) {
      if (!this.isProfileEnabled() || !console.time) {
        return func();
      }
      console.time(name);
      const result = func();
      console.timeEnd(name);
      return result;
    }
    /** @internal */
    log(view, kind, msgCallback, diagnostic) {
      const debugEnabled = this.isDebugEnabled();
      const level = diagnostic?.level ?? "debug";
      const emitDiagnostic = !!diagnostic && (level !== "debug" || debugEnabled);
      if (!this.viewLogger && !debugEnabled && !emitDiagnostic) {
        return;
      }
      const [message, obj] = msgCallback();
      if (this.viewLogger) {
        this.viewLogger(view, kind, message, obj);
      } else if (debugEnabled) {
        debug(view, kind, message, obj);
      }
      if (emitDiagnostic && diagnostic) {
        dispatchDiagnostic({
          level,
          code: diagnostic.code,
          message,
          viewId: view.id,
          metadata: diagnostic.metadata?.(),
          ...diagnostic.context || { attribution: "unknown" }
        });
      }
    }
    /** @internal */
    requestDOMUpdate(callback) {
      this.transitions.after(callback);
    }
    /** @internal */
    asyncTransition(promise) {
      this.transitions.addAsyncTransition(promise);
    }
    /** @internal */
    transition(time, onStart, onDone = function() {
    }) {
      this.transitions.addTransition(time, onStart, onDone);
    }
    /** @internal */
    onChannel(channel, event, cb) {
      channel.on(event, (data) => {
        const latency = this.getLatencySim();
        if (!latency) {
          cb(data);
        } else {
          setTimeout(() => cb(data), latency);
        }
      });
    }
    /** @internal */
    reloadWithJitter(view, log) {
      this.reloadWithJitterTimer != null && clearTimeout(this.reloadWithJitterTimer);
      this.disconnect();
      const minMs = this.reloadJitterMin;
      const maxMs = this.reloadJitterMax;
      let afterMs = Math.floor(Math.random() * (maxMs - minMs + 1)) + minMs;
      const tries = browser_default.updateLocal(
        this.localStorage,
        window.location.pathname,
        CONSECUTIVE_RELOADS,
        0,
        (count) => count + 1
      );
      if (tries >= this.maxReloads) {
        afterMs = this.failsafeJitter;
      }
      this.reloadWithJitterTimer = setTimeout(() => {
        if (view.isDestroyed() || view.isConnected()) {
          return;
        }
        view.destroy();
        log ? log() : this.log(
          view,
          "join",
          () => [`encountered ${tries} consecutive reloads`],
          {
            code: "view.reload-attempts",
            metadata: () => ({ tries })
          }
        );
        if (tries >= this.maxReloads) {
          this.log(
            view,
            "join",
            () => [
              `exceeded ${this.maxReloads} consecutive reloads. Entering failsafe mode`
            ],
            {
              code: "view.reload-failsafe",
              level: "error",
              metadata: () => ({ tries, maxReloads: this.maxReloads })
            }
          );
        }
        if (this.pendingLink !== null) {
          window.location.href = this.pendingLink;
        } else {
          window.location.reload();
        }
      }, afterMs);
    }
    /** @internal */
    getHookDefinition(name) {
      if (!name) {
        return;
      }
      return this.maybeInternalHook(name) || this.hooks[name] || this.maybeRuntimeHook(name);
    }
    /** @internal */
    maybeInternalHook(name) {
      return name && name.startsWith("Phoenix.") && hooks_default[name.split(".")[1]];
    }
    /** @internal */
    maybeRuntimeHook(name) {
      const runtimeHook = document.querySelector(
        `script[${PHX_RUNTIME_HOOK}="${CSS.escape(name)}"]`
      );
      if (!runtimeHook) {
        return;
      }
      let callbacks = window[`phx_hook_${name}`];
      if (!callbacks || typeof callbacks !== "function") {
        logError(
          "hook.runtime-not-function",
          "a runtime hook must be a function",
          {
            runtimeHook,
            name
          },
          { attribution: "app" }
        );
        return;
      }
      const hookDefiniton = callbacks();
      if (hookDefiniton && (typeof hookDefiniton === "object" || typeof hookDefiniton === "function")) {
        return hookDefiniton;
      }
      logError(
        "hook.runtime-invalid-return",
        "runtime hook must return an object with hook callbacks or an instance of ViewHook",
        { runtimeHook, name },
        { attribution: "app" }
      );
    }
    /** @internal */
    isUnloaded() {
      return this.unloaded;
    }
    /** @internal */
    isConnected() {
      return this.socket.isConnected();
    }
    /** @internal */
    getBindingPrefix() {
      return this.bindingPrefix;
    }
    /** @internal */
    binding(kind) {
      return `${this.getBindingPrefix()}${kind}`;
    }
    /** @internal */
    channel(topic, params) {
      return this.socket.channel(topic, params);
    }
    /** @internal */
    joinDeadView() {
      const body = document.body;
      if (body && !this.isPhxView(body) && !this.isPhxView(document.firstElementChild)) {
        const view = this.newRootView(body);
        view.setHref(this.getHref());
        view.joinDead();
        if (!this.main) {
          this.main = view;
        }
        window.requestAnimationFrame(() => {
          view.execNewMounted();
          this.maybeScroll(history.state?.scroll);
        });
      }
    }
    /** @internal */
    joinRootViews() {
      let rootsFound = false;
      dom_default.all(
        document,
        `${PHX_VIEW_SELECTOR}:not([${PHX_PARENT_ID}])`,
        (rootEl) => {
          if (!this.getRootById(rootEl.id)) {
            const view = this.newRootView(rootEl);
            if (!dom_default.isPhxSticky(rootEl)) {
              view.setHref(this.getHref());
            }
            view.join();
            if (rootEl.hasAttribute(PHX_MAIN)) {
              this.main = view;
            }
          }
          rootsFound = true;
        }
      );
      return rootsFound;
    }
    /** @internal */
    redirect(to, flash, reloadToken) {
      if (reloadToken) {
        browser_default.setCookie(PHX_RELOAD_STATUS, reloadToken, 60);
      }
      this.unload();
      browser_default.redirect(to, flash);
    }
    /** @internal */
    replaceMain(href, flash, callback = null, linkRef = this.setPendingLink(href)) {
      if (!this.main) {
        return;
      }
      const liveReferer = this.currentLocation.href;
      this.outgoingMainEl = this.outgoingMainEl || this.main.el;
      const stickies = dom_default.findPhxSticky(document) || [];
      const removeEls = this.phxRemoveElementsForNavigation(
        this.outgoingMainEl,
        stickies
      );
      const newMainEl = dom_default.cloneNode(this.outgoingMainEl, "");
      const oldMainView = this.main;
      oldMainView.showLoader(this.loaderTimeout);
      oldMainView.destroy();
      this.main = this.newRootView(newMainEl, flash, liveReferer);
      this.main.setRedirect(href);
      this.transitionRemoves(removeEls, oldMainView);
      this.main.join((joinCount, onDone) => {
        if (joinCount === 1 && this.commitPendingLink(linkRef)) {
          this.requestDOMUpdate(() => {
            removeEls.forEach((el) => {
              if (!el.isSameNode(this.outgoingMainEl)) {
                el.remove();
              }
            });
            stickies.forEach((el) => newMainEl.appendChild(el));
            this.outgoingMainEl.replaceWith(newMainEl);
            this.outgoingMainEl = null;
            callback && callback(linkRef);
            onDone();
          });
        }
      });
    }
    phxRemoveElementsForNavigation(mainEl, stickies = dom_default.findPhxSticky(document) || []) {
      const removeSelector = `[${this.binding("remove")}]`;
      const removeEls = this.cascadePhxRemoveOnNavigation ? [mainEl, ...dom_default.all(mainEl, removeSelector)] : [mainEl];
      return removeEls.filter(
        (el) => el.matches(removeSelector) && !dom_default.isChildOfAny(el, stickies)
      );
    }
    /** @internal */
    transitionRemoves(elements, view, callback) {
      const removeAttr = this.binding("remove");
      const silenceEvents = (e) => {
        e.preventDefault();
        e.stopImmediatePropagation();
      };
      elements.forEach((el) => {
        for (const event of this.boundEventNames) {
          el.addEventListener(event, silenceEvents, true);
        }
        const e = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
        js_default.exec(e, "remove", el.getAttribute(removeAttr), view, el);
      });
      this.requestDOMUpdate(() => {
        elements.forEach((el) => {
          for (const event of this.boundEventNames) {
            el.removeEventListener(event, silenceEvents, true);
          }
        });
        callback && callback();
      });
    }
    /** @internal */
    isPhxView(el) {
      return el.getAttribute && el.getAttribute(PHX_SESSION) !== null;
    }
    /** @internal */
    newRootView(el, flash, liveReferer) {
      const view = new View(el, this, null, flash, liveReferer);
      this.roots[view.id] = view;
      return view;
    }
    /** @internal */
    owner(childEl, callback) {
      let view;
      const viewEl = dom_default.closestViewEl(childEl);
      if (viewEl) {
        view = dom_default.private(viewEl, "view");
      } else {
        if (!childEl.isConnected) {
          return null;
        }
        view = this.main;
      }
      return view && callback ? callback(view) : view;
    }
    /** @internal */
    withinOwners(childEl, callback) {
      this.owner(childEl, (view) => callback(view, childEl));
    }
    /** @internal */
    getViewByEl(el) {
      const rootId = el.getAttribute(PHX_ROOT_ID);
      return maybe(
        this.getRootById(rootId),
        (root) => root.getDescendentByEl(el)
      );
    }
    /** @internal */
    getRootById(id) {
      return this.roots[id];
    }
    /** @internal */
    destroyAllViews() {
      for (const id in this.roots) {
        this.roots[id].destroy();
        delete this.roots[id];
      }
      this.main = null;
    }
    /** @internal */
    destroyViewByEl(el) {
      const root = this.getRootById(el.getAttribute(PHX_ROOT_ID));
      if (root && root.id === el.id) {
        root.destroy();
        delete this.roots[root.id];
      } else if (root) {
        root.destroyDescendent(el.id);
      }
    }
    /** @internal */
    getActiveElement() {
      return document.activeElement;
    }
    /** @internal */
    dropActiveElement(view) {
      if (this.prevActive && view.ownsElement(this.prevActive)) {
        this.prevActive = null;
      }
    }
    /** @internal */
    restorePreviouslyActiveFocus() {
      if (this.prevActive && this.prevActive !== document.body && this.prevActive instanceof HTMLElement) {
        this.prevActive.focus();
      }
    }
    /** @internal */
    blurActiveElement() {
      this.prevActive = this.getActiveElement();
      if (this.prevActive !== document.body && this.prevActive instanceof HTMLElement) {
        this.prevActive.blur();
      }
    }
    /** @internal */
    bindTopLevelEvents({ dead } = {}) {
      if (this.serverCloseRef === null) {
        this.serverCloseRef = this.socket.onClose((event) => {
          if (event && event.code === 1e3 && this.main) {
            return this.reloadWithJitter(this.main);
          }
        });
      }
      if (this.boundTopLevelEvents) {
        return;
      }
      this.boundTopLevelEvents = true;
      document.body.addEventListener("click", function() {
      });
      window.addEventListener(
        "pageshow",
        (e) => {
          if (e.persisted) {
            this.getSocket().disconnect();
            this.withPageLoading({ to: window.location.href, kind: "redirect" });
            window.location.reload();
          }
        },
        true
      );
      if (!dead) {
        this.bindNav();
      }
      this.bindClicks();
      if (!dead) {
        this.bindForms();
      }
      this.bind(
        { keyup: "keyup", keydown: "keydown" },
        (e, type, view, targetEl, phxEvent, _phxTarget) => {
          const matchKey = targetEl.getAttribute(this.binding(PHX_KEY));
          const pressedKey = e.key && e.key.toLowerCase();
          if (matchKey && matchKey.toLowerCase() !== pressedKey) {
            return;
          }
          const data = { key: e.key, ...this.eventMeta(type, e, targetEl) };
          js_default.exec(e, type, phxEvent, view, targetEl, ["push", { data }]);
        }
      );
      this.bind(
        { blur: "focusout", focus: "focusin" },
        (e, type, view, targetEl, phxEvent, phxTarget) => {
          if (!phxTarget) {
            const data = { ...this.eventMeta(type, e, targetEl) };
            js_default.exec(e, type, phxEvent, view, targetEl, ["push", { data }]);
          }
        }
      );
      this.bind(
        { blur: "blur", focus: "focus" },
        (e, type, view, targetEl, phxEvent, phxTarget) => {
          if (phxTarget === "window") {
            const data = this.eventMeta(type, e, targetEl);
            js_default.exec(e, type, phxEvent, view, targetEl, ["push", { data }]);
          }
        }
      );
      this.on("dragover", (e) => e.preventDefault());
      const dropTargetDragDepths = /* @__PURE__ */ new WeakMap();
      this.on("dragenter", (e) => {
        let target = e.target && dom_default.elementFromTarget(e.target);
        if (!target) {
          return;
        }
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        if (eventContainsFiles(e)) {
          const dragDepth = (dropTargetDragDepths.get(dropzone) || 0) + 1;
          dropTargetDragDepths.set(dropzone, dragDepth);
          if (dragDepth === 1) {
            this.js().addClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
          }
        }
      });
      this.on("dragleave", (e) => {
        let target = e.target && dom_default.elementFromTarget(e.target);
        if (!target) {
          return;
        }
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        const dragDepth = dropTargetDragDepths.get(dropzone);
        if (dragDepth === void 0) {
          return;
        } else if (dragDepth > 1) {
          dropTargetDragDepths.set(dropzone, dragDepth - 1);
        } else {
          dropTargetDragDepths.delete(dropzone);
          this.js().removeClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
        }
      });
      this.on("drop", (e) => {
        let target = e.target && dom_default.elementFromTarget(e.target);
        if (!target) {
          return;
        }
        e.preventDefault();
        const dropzone = closestPhxBinding(target, this.binding(PHX_DROP_TARGET));
        if (!dropzone || !(dropzone instanceof HTMLElement)) {
          return;
        }
        dropTargetDragDepths.delete(dropzone);
        this.js().removeClass(dropzone, PHX_DROP_TARGET_ACTIVE_CLASS);
        if (!e.dataTransfer) {
          return;
        }
        const dropTargetId = dropzone.getAttribute(this.binding(PHX_DROP_TARGET));
        const dropTarget = dropTargetId && document.getElementById(dropTargetId);
        const files = Array.from(e.dataTransfer.files || []);
        if (!dropTarget || !(dropTarget instanceof HTMLInputElement) || dropTarget.disabled || files.length === 0 || !(dropTarget.files instanceof FileList)) {
          return;
        }
        LiveUploader.trackFiles(dropTarget, files, e.dataTransfer);
        dropTarget.dispatchEvent(new Event("input", { bubbles: true }));
      });
      this.on(PHX_TRACK_UPLOADS, (e) => {
        const uploadTarget = e.target && dom_default.elementFromTarget(e.target);
        if (!dom_default.isUploadInput(uploadTarget)) {
          return;
        }
        const files = Array.from(e.detail.files || []).filter(
          (f) => f instanceof File || f instanceof Blob
        );
        LiveUploader.trackFiles(uploadTarget, files);
        uploadTarget.dispatchEvent(new Event("input", { bubbles: true }));
      });
    }
    /** @internal */
    eventMeta(eventName, e, targetEl) {
      const callback = this.metadataCallbacks[eventName];
      return callback ? callback(e, targetEl) : {};
    }
    /** @internal */
    setPendingLink(href) {
      this.linkRef++;
      this.pendingLink = href;
      this.resetReloadStatus();
      return this.linkRef;
    }
    /**
     * @internal
     * anytime we are navigating or connecting, drop reload cookie in case
     * we issue the cookie but the next request was interrupted and the server never dropped it
     */
    resetReloadStatus() {
      browser_default.deleteCookie(PHX_RELOAD_STATUS);
    }
    /** @internal */
    commitPendingLink(linkRef) {
      if (this.linkRef !== linkRef) {
        return false;
      }
      if (this.pendingLink !== null) {
        this.href = this.pendingLink;
        this.pendingLink = null;
      }
      return true;
    }
    /** @internal */
    getHref() {
      return this.href;
    }
    /** @internal */
    hasPendingLink() {
      return !!this.pendingLink;
    }
    /** @internal */
    bind(events, callback) {
      for (const event in events) {
        const browserEventName = events[event];
        this.on(browserEventName, (e) => {
          const binding = this.binding(event);
          const windowBinding = this.binding(`window-${event}`);
          const targetPhxEvent = e.target instanceof Element && e.target.getAttribute(binding);
          if (!(e.target instanceof Element)) {
            return;
          }
          if (targetPhxEvent) {
            this.debounce(e.target, e, browserEventName, () => {
              this.withinOwners(e.target, (view) => {
                callback(
                  e,
                  event,
                  view,
                  e.target,
                  targetPhxEvent,
                  null
                );
              });
            });
          } else {
            dom_default.all(document, `[${windowBinding}]`, (el) => {
              const phxEvent = el.getAttribute(windowBinding);
              this.debounce(el, e, browserEventName, () => {
                this.withinOwners(el, (view) => {
                  callback(
                    e,
                    event,
                    view,
                    el,
                    phxEvent,
                    "window"
                  );
                });
              });
            });
          }
        });
      }
    }
    /** @internal */
    bindClicks() {
      this.on("mousedown", (e) => this.clickStartedAtTarget = e.target);
      this.bindClick();
    }
    /** @internal */
    bindClick() {
      const click = this.binding("click");
      window.addEventListener(
        "click",
        (e) => {
          let target = e.target && dom_default.elementFromTarget(e.target);
          if (!target) {
            return;
          }
          if (e.detail === 0)
            this.clickStartedAtTarget = target;
          const clickStartedAtTarget = this.clickStartedAtTarget || target;
          target = closestPhxBinding(target, click);
          this.dispatchClickAway(e, clickStartedAtTarget);
          this.clickStartedAtTarget = null;
          if (!target) {
            return;
          }
          const phxEvent = target.getAttribute(click);
          if (!phxEvent) {
            if (dom_default.isNewPageClick(e, window.location)) {
              this.unload();
            }
            return;
          }
          if (target.getAttribute("href") === "#") {
            e.preventDefault();
          }
          if (target.hasAttribute(PHX_REF_SRC)) {
            return;
          }
          this.debounce(target, e, "click", () => {
            this.withinOwners(target, (view) => {
              js_default.exec(e, "click", phxEvent, view, target, [
                "push",
                { data: this.eventMeta("click", e, target) }
              ]);
            });
          });
        },
        false
      );
    }
    /** @internal */
    dispatchClickAway(e, clickStartedAt) {
      const phxClickAway = this.binding("click-away");
      const portal = clickStartedAt.closest(`[${PHX_TELEPORTED_SRC}]`);
      const portalStartedAt = portal && dom_default.byId(portal.getAttribute(PHX_TELEPORTED_SRC));
      dom_default.all(document, `[${phxClickAway}]`, (el) => {
        let startedAt = clickStartedAt;
        if (portal && !portal.contains(el)) {
          startedAt = portalStartedAt;
        }
        if (!(el.isSameNode(startedAt) || el.contains(startedAt) || // When clicking a link with custom method,
        // phoenix_html triggers a click on a submit button
        // of a hidden form appended to the body. For such cases
        // where the clicked target is hidden, we skip click-away.
        //
        // Also, when we have a portal, we don't want to check the visibility
        // of the portal source, as it's a <template> that is always not visible.
        // Instead, check the visibility of the original click target.
        !js_default.isVisible(clickStartedAt))) {
          this.withinOwners(el, (view) => {
            const phxEvent = el.getAttribute(phxClickAway);
            if (js_default.isVisible(el) && js_default.isInViewport(el)) {
              js_default.exec(e, "click", phxEvent, view, el, [
                "push",
                { data: this.eventMeta("click", e, e.target) }
              ]);
            }
          });
        }
      });
    }
    /** @internal */
    bindNav() {
      if (!browser_default.canPushState()) {
        return;
      }
      if (history.scrollRestoration) {
        history.scrollRestoration = "manual";
      }
      let scrollTimer = null;
      window.addEventListener("scroll", (_e) => {
        scrollTimer != null && clearTimeout(scrollTimer);
        scrollTimer = setTimeout(() => {
          browser_default.updateCurrentState(
            (state) => Object.assign(state, { scroll: window.scrollY })
          );
        }, 100);
      });
      window.addEventListener(
        "popstate",
        (event) => {
          if (!this.isNewLocation(window.location)) {
            return;
          }
          const { type, backType, id, scroll, position } = event.state || {};
          const href = window.location.href;
          const isForward = position > this.currentHistoryPosition;
          const navType = isForward ? type : backType || type;
          const direction = isForward ? "forward" : "backward";
          const detail = {
            href,
            patch: navType === "patch",
            pop: true,
            direction
          };
          if (!this.dispatchBeforeNavigate(detail)) {
            if (isForward) {
              history.back();
            } else {
              history.forward();
            }
            return;
          }
          this.registerNewLocation(window.location);
          this.currentHistoryPosition = position || 0;
          this.sessionStorage.setItem(
            PHX_LV_HISTORY_POSITION,
            this.currentHistoryPosition.toString()
          );
          dom_default.dispatchEvent(window, "phx:navigate", { detail });
          this.requestDOMUpdate(() => {
            const callback = () => {
              this.maybeScroll(scroll);
            };
            if (this.main && this.main.isConnected() && navType === "patch" && id === this.main.id) {
              this.main.pushLinkPatch(event, href, null, callback);
            } else {
              this.replaceMain(href, null, callback);
            }
          });
        },
        false
      );
      window.addEventListener(
        "click",
        (e) => {
          let el = e.target && dom_default.elementFromTarget(e.target);
          if (!el) {
            return;
          }
          const target = closestPhxBinding(
            el,
            PHX_LIVE_LINK
          );
          const type = target && target.getAttribute(PHX_LIVE_LINK);
          if (!type || !this.isConnected() || !this.main || dom_default.wantsNewTab(e, target)) {
            return;
          }
          const href = target.href instanceof SVGAnimatedString ? target.href.baseVal : target.href;
          const linkState = target.getAttribute(PHX_LINK_STATE);
          if (linkState !== "replace" && linkState !== "push") {
            throw new Error(
              `expected ${PHX_LINK_STATE} to be "replace" or "push", got: ${linkState}`
            );
          }
          if (type !== "patch" && type !== "redirect") {
            throw new Error(
              `expected ${PHX_LIVE_LINK} to be "patch" or "redirect", got: ${type}`
            );
          }
          e.preventDefault();
          e.stopImmediatePropagation();
          if (this.pendingLink === href) {
            return;
          }
          const detail = {
            href,
            patch: type === "patch",
            pop: false,
            direction: "forward"
          };
          const phxClick = target.getAttribute(this.binding("click"));
          const execPhxClick = () => {
            if (phxClick) {
              this.requestDOMUpdate(() => this.execJS(target, phxClick, "click"));
            }
          };
          if (!this.dispatchBeforeNavigate(detail)) {
            execPhxClick();
            return;
          }
          this.requestDOMUpdate(() => {
            if (type === "patch") {
              this.pushHistoryPatch(e, href, linkState, target);
            } else {
              this.historyRedirect(e, href, linkState, null, target);
            }
            execPhxClick();
          });
        },
        false
      );
    }
    /** @internal */
    maybeScroll(scroll) {
      if (typeof scroll === "number") {
        requestAnimationFrame(() => {
          window.scrollTo(0, scroll);
        });
      }
    }
    /** @internal */
    dispatchEvent(event, payload = {}) {
      dom_default.dispatchEvent(window, `phx:${event}`, { detail: payload });
    }
    /** @internal */
    dispatchEvents(events) {
      events.forEach(([event, payload]) => this.dispatchEvent(event, payload));
    }
    /** @internal */
    withPageLoading(info, callback) {
      dom_default.dispatchEvent(window, "phx:page-loading-start", { detail: info });
      const done = () => dom_default.dispatchEvent(window, "phx:page-loading-stop", { detail: info });
      return callback ? callback(done) : done;
    }
    /** @internal */
    dispatchBeforeNavigate(detail) {
      return dom_default.dispatchEvent(window, "phx:before-navigate", { detail });
    }
    /** @internal */
    pushHistoryPatch(e, href, linkState, targetEl) {
      if (!this.isConnected() || !(this.main && this.main.isMain())) {
        return browser_default.redirect(href);
      }
      this.withPageLoading({ to: href, kind: "patch" }, (done) => {
        this.main.pushLinkPatch(e, href, targetEl, (linkRef) => {
          this.historyPatch(href, linkState, linkRef);
          done();
        });
      });
    }
    /** @internal */
    historyPatch(href, linkState, linkRef = this.setPendingLink(href)) {
      if (!this.commitPendingLink(linkRef)) {
        return;
      }
      this.currentHistoryPosition++;
      this.sessionStorage.setItem(
        PHX_LV_HISTORY_POSITION,
        this.currentHistoryPosition.toString()
      );
      browser_default.updateCurrentState((state) => ({ ...state, backType: "patch" }));
      browser_default.pushState(
        linkState,
        {
          type: "patch",
          id: this.main.id,
          position: this.currentHistoryPosition
        },
        href
      );
      dom_default.dispatchEvent(window, "phx:navigate", {
        detail: { patch: true, href, pop: false, direction: "forward" }
      });
      this.registerNewLocation(window.location);
    }
    /** @internal */
    historyRedirect(e, href, linkState, flash, targetEl) {
      const clickLoading = targetEl && e.isTrusted && e.type !== "popstate";
      if (clickLoading) {
        targetEl.classList.add("phx-click-loading");
      }
      if (!this.isConnected() || !(this.main && this.main.isMain())) {
        return browser_default.redirect(href, flash);
      }
      if (/^\/$|^\/[^\/]+.*$/.test(href)) {
        const { protocol, host } = window.location;
        href = `${protocol}//${host}${href}`;
      }
      const scroll = window.scrollY;
      this.withPageLoading({ to: href, kind: "redirect" }, (done) => {
        this.replaceMain(href, flash, (linkRef) => {
          if (linkRef === this.linkRef) {
            this.currentHistoryPosition++;
            this.sessionStorage.setItem(
              PHX_LV_HISTORY_POSITION,
              this.currentHistoryPosition.toString()
            );
            browser_default.updateCurrentState((state) => ({
              ...state,
              backType: "redirect"
            }));
            browser_default.pushState(
              linkState,
              {
                type: "redirect",
                id: this.main.id,
                scroll,
                position: this.currentHistoryPosition
              },
              href
            );
            dom_default.dispatchEvent(window, "phx:navigate", {
              detail: { href, patch: false, pop: false, direction: "forward" }
            });
            this.registerNewLocation(window.location);
          }
          if (clickLoading) {
            targetEl.classList.remove("phx-click-loading");
          }
          done();
        });
      });
    }
    /** @internal */
    registerNewLocation(newLocation) {
      if (!this.isNewLocation(newLocation)) {
        return false;
      } else {
        this.currentLocation = clone(newLocation);
        return true;
      }
    }
    /** @internal */
    isNewLocation(newLocation) {
      const { pathname, search } = this.currentLocation;
      if (pathname + search === newLocation.pathname + newLocation.search) {
        return false;
      } else {
        return true;
      }
    }
    /** @internal */
    bindForms() {
      let iterations = 0;
      let externalFormSubmitted = false;
      this.on("submit", (e) => {
        if (!(e.target instanceof HTMLFormElement))
          return;
        const phxSubmit = e.target.getAttribute(this.binding("submit"));
        const phxChange = e.target.getAttribute(this.binding("change"));
        if (!externalFormSubmitted && phxChange && !phxSubmit) {
          externalFormSubmitted = true;
          e.preventDefault();
          this.withinOwners(e.target, (view) => {
            view.disableForm(e.target, phxChange);
            window.requestAnimationFrame(() => {
              if (dom_default.isUnloadableFormSubmit(e)) {
                this.unload();
              }
              e.target.submit();
            });
          });
        }
      });
      this.on("submit", (e) => {
        if (!(e.target instanceof HTMLFormElement))
          return;
        const phxEvent = e.target.getAttribute(this.binding("submit"));
        if (!phxEvent) {
          if (dom_default.isUnloadableFormSubmit(e)) {
            this.unload();
          }
          return;
        }
        e.preventDefault();
        this.withinOwners(e.target, (view) => {
          js_default.exec(e, "submit", phxEvent, view, e.target, [
            "push",
            { submitter: e.submitter }
          ]);
        });
      });
      for (const type of ["change", "input"]) {
        this.on(type, (e) => {
          if (!dom_default.isFormAssociated(e.target)) {
            return;
          }
          if (e instanceof CustomEvent && e.target.form === void 0) {
            if (e.detail && e.detail.dispatcher) {
              throw new Error(
                `dispatching a custom ${type} event is only supported on input elements inside a form`
              );
            }
            return;
          }
          const input = e.target;
          const phxChange = this.binding("change");
          if (this.blockPhxChangeWhileComposing && e instanceof InputEvent && e.isComposing) {
            const key = `composition-listener-${type}`;
            if (!dom_default.private(input, key)) {
              dom_default.putPrivate(input, key, true);
              input.addEventListener(
                "compositionend",
                () => {
                  input.dispatchEvent(new Event(type, { bubbles: true }));
                  dom_default.deletePrivate(input, key);
                },
                { once: true }
              );
            }
            return;
          }
          const inputEvent = input.getAttribute(phxChange);
          const formEvent = input.form && input.form.getAttribute(phxChange);
          const phxEvent = inputEvent || formEvent;
          if (!phxEvent) {
            return;
          }
          if (input.type === "number" && input.validity && input.validity.badInput) {
            return;
          }
          const dispatcher = inputEvent ? input : input.form;
          const currentIterations = iterations;
          iterations++;
          const { at, type: lastType } = dom_default.private(input, "prev-iteration") || {};
          if (at === currentIterations - 1 && type === "change" && lastType === "input") {
            return;
          }
          dom_default.putPrivate(input, "prev-iteration", {
            at: currentIterations,
            type
          });
          this.debounce(input, e, type, () => {
            this.withinOwners(dispatcher, (view) => {
              dom_default.putPrivate(input, PHX_HAS_FOCUSED, true);
              js_default.exec(e, "change", phxEvent, view, input, [
                "push",
                { _target: input.name, dispatcher }
              ]);
            });
          });
        });
      }
      this.on("reset", (e) => {
        const form = e.target;
        dom_default.resetForm(form);
        const input = Array.from(form.elements).find(
          (el) => "type" in el && el.type === "reset"
        );
        if (input) {
          window.requestAnimationFrame(() => {
            input.dispatchEvent(
              new Event("input", { bubbles: true, cancelable: false })
            );
          });
        }
      });
    }
    /** @internal */
    debounce(el, event, eventType, callback) {
      if (eventType === "blur" || eventType === "focusout") {
        return callback();
      }
      const phxDebounce = this.binding(PHX_DEBOUNCE);
      const phxThrottle = this.binding(PHX_THROTTLE);
      const defaultDebounce = this.defaults.debounce.toString();
      const defaultThrottle = this.defaults.throttle.toString();
      this.withinOwners(el, (view) => {
        const asyncFilter = () => !view.isDestroyed() && document.body.contains(el);
        dom_default.debounce(
          el,
          event,
          phxDebounce,
          defaultDebounce,
          phxThrottle,
          defaultThrottle,
          asyncFilter,
          () => {
            callback();
          }
        );
      });
    }
    /** @internal */
    silenceEvents(callback) {
      this.silenced = true;
      callback();
      this.silenced = false;
    }
    /** @internal */
    on(event, callback) {
      this.boundEventNames.add(event);
      window.addEventListener(event, (e) => {
        if (!this.silenced) {
          callback(e);
        }
      });
    }
    /** @internal */
    jsQuerySelectorAll(sourceEl, query, defaultQuery) {
      const all = this.domCallbacks.jsQuerySelectorAll;
      return all ? all(sourceEl, query, defaultQuery) : defaultQuery();
    }
  };
  var TransitionSet = class {
    constructor() {
      this.transitions = /* @__PURE__ */ new Set();
      this.promises = /* @__PURE__ */ new Set();
      this.pendingOps = [];
    }
    reset() {
      this.transitions.forEach((timer) => {
        clearTimeout(timer);
        this.transitions.delete(timer);
      });
      this.promises.clear();
      this.flushPendingOps();
    }
    after(callback) {
      if (this.size() === 0) {
        callback();
      } else {
        this.pushPendingOp(callback);
      }
    }
    addTransition(time, onStart, onDone) {
      onStart();
      const timer = setTimeout(() => {
        this.transitions.delete(timer);
        onDone();
        this.flushPendingOps();
      }, time);
      this.transitions.add(timer);
    }
    addAsyncTransition(promise) {
      this.promises.add(promise);
      promise.then(() => {
        this.promises.delete(promise);
        this.flushPendingOps();
      });
    }
    pushPendingOp(op) {
      this.pendingOps.push(op);
    }
    size() {
      return this.transitions.size + this.promises.size;
    }
    flushPendingOps() {
      if (this.size() > 0) {
        return;
      }
      const op = this.pendingOps.shift();
      if (op) {
        op();
        this.flushPendingOps();
      }
    }
  };

  // js/app.js
  var import_cropper = __toESM(require_cropper());
  var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
  var Hooks2 = {};
  Hooks2.CopyToClipboard = {
    mounted() {
      this.el.addEventListener("click", () => {
        let text = this.el.dataset.clipboardText;
        if (text) {
          navigator.clipboard.writeText(text).then(() => {
            let originalHtml = this.el.innerHTML;
            this.el.innerHTML = "<span>\u2713 Kopiert!</span>";
            setTimeout(() => {
              this.el.innerHTML = originalHtml;
            }, 2e3);
          }).catch((err) => {
            console.error("Clipboard copy failed:", err);
          });
        }
      });
    }
  };
  Hooks2.ImageCropper = {
    mounted() {
      const fileInput = this.el.querySelector("input[type=file]");
      const modalId = this.el.dataset.modalId || "cropper-modal";
      const previewId = this.el.dataset.previewId || "cropper-preview-img";
      const confirmBtnId = this.el.dataset.confirmBtnId || "cropper-confirm-btn";
      const cancelBtnId = this.el.dataset.cancelBtnId || "cropper-cancel-btn";
      let cropper = null;
      if (!fileInput) return;
      fileInput.addEventListener("change", (e) => {
        const file = e.target.files[0];
        if (!file) return;
        if (file.size > 5 * 1024 * 1024) {
          alert("Die Datei darf maximal 5MB gro\xDF sein.");
          fileInput.value = "";
          return;
        }
        const modal = document.getElementById(modalId);
        const previewImg = document.getElementById(previewId);
        if (!modal || !previewImg) return;
        const reader = new FileReader();
        reader.onload = (event) => {
          if (cropper) {
            cropper.destroy();
            cropper = null;
          }
          modal.classList.remove("hidden");
          previewImg.onload = () => {
            cropper = new import_cropper.default(previewImg, {
              aspectRatio: 1,
              viewMode: 1,
              autoCropArea: 0.9,
              responsive: true,
              guides: true,
              center: true,
              highlight: false,
              cropBoxMovable: true,
              cropBoxResizable: true
            });
          };
          previewImg.src = event.target.result;
        };
        reader.readAsDataURL(file);
      });
      this.confirmHandler = (e) => {
        const btn = e.target.closest(`#${confirmBtnId}`);
        if (!btn) return;
        if (!cropper) return;
        const canvas = cropper.getCroppedCanvas({
          minWidth: 512,
          minHeight: 512,
          width: 512,
          height: 512,
          imageSmoothingEnabled: true,
          imageSmoothingQuality: "high"
        });
        if (!canvas) {
          alert("Das Bild konnte nicht zugeschnitten werden. Bitte versuchen Sie es erneut.");
          return;
        }
        const base64Data = canvas.toDataURL("image/png");
        const targetEvent = this.el.dataset.event || "save_cropped_image";
        this.pushEvent(targetEvent, {
          data: base64Data,
          content_type: "image/png"
        });
        const modal = document.getElementById(modalId);
        if (modal) modal.classList.add("hidden");
        if (cropper) {
          cropper.destroy();
          cropper = null;
        }
        fileInput.value = "";
      };
      this.cancelHandler = (e) => {
        const btn = e.target.closest(`#${cancelBtnId}`);
        if (!btn) return;
        const modal = document.getElementById(modalId);
        if (modal) modal.classList.add("hidden");
        if (cropper) {
          cropper.destroy();
          cropper = null;
        }
        fileInput.value = "";
      };
      document.addEventListener("click", this.confirmHandler);
      document.addEventListener("click", this.cancelHandler);
    },
    destroyed() {
      if (this.confirmHandler) document.removeEventListener("click", this.confirmHandler);
      if (this.cancelHandler) document.removeEventListener("click", this.cancelHandler);
    }
  };
  Hooks2.FacilityMap = {
    mounted() {
      this.canvasEl = this.el.querySelector("#facility-map-canvas") || this.el;
      this.tileUrl = this.el.dataset.tileUrl || "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
      this.attribution = this.el.dataset.attribution || "";
      this.editable = this.el.dataset.editable === "true";
      try {
        this.addresses = JSON.parse(this.el.dataset.addresses || "[]");
      } catch (_) {
        this.addresses = [];
      }
      try {
        this.polygon = JSON.parse(this.el.dataset.polygon || "[]");
      } catch (_) {
        this.polygon = [];
      }
      this.zoom = 17;
      this.draggingIdx = null;
      this.initDOM();
      this.renderMap();
      this.handleEvent("facility_map:update", ({ addresses, polygon }) => {
        this.addresses = addresses || [];
        this.polygon = polygon || [];
        this.renderMap();
      });
      this.onResize = () => this.renderMap();
      window.addEventListener("resize", this.onResize);
    },
    destroyed() {
      if (this.onResize) window.removeEventListener("resize", this.onResize);
      if (this.onMouseMove) document.removeEventListener("mousemove", this.onMouseMove);
      if (this.onMouseUp) document.removeEventListener("mouseup", this.onMouseUp);
    },
    initDOM() {
      this.canvasEl.innerHTML = "";
      this.canvasEl.style.position = "relative";
      this.canvasEl.style.userSelect = "none";
      this.tileLayer = document.createElement("div");
      this.tileLayer.style.position = "absolute";
      this.tileLayer.style.inset = "0";
      this.tileLayer.style.overflow = "hidden";
      this.canvasEl.appendChild(this.tileLayer);
      this.svgOverlay = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      this.svgOverlay.style.position = "absolute";
      this.svgOverlay.style.inset = "0";
      this.svgOverlay.style.width = "100%";
      this.svgOverlay.style.height = "100%";
      this.canvasEl.appendChild(this.svgOverlay);
      this.markerLayer = document.createElement("div");
      this.markerLayer.style.position = "absolute";
      this.markerLayer.style.inset = "0";
      this.markerLayer.style.pointerEvents = "none";
      this.canvasEl.appendChild(this.markerLayer);
      this.attrEl = document.createElement("div");
      this.attrEl.style.position = "absolute";
      this.attrEl.style.bottom = "4px";
      this.attrEl.style.right = "8px";
      this.attrEl.style.padding = "2px 6px";
      this.attrEl.style.background = "rgba(255,255,255,0.85)";
      this.attrEl.style.borderRadius = "4px";
      this.attrEl.style.fontSize = "10px";
      this.attrEl.innerHTML = this.attribution;
      this.canvasEl.appendChild(this.attrEl);
      this.onMouseMove = (e) => {
        if (this.draggingIdx === null) return;
        const rect = this.canvasEl.getBoundingClientRect();
        const px = e.clientX - rect.left;
        const py = e.clientY - rect.top;
        const { lat, lon } = this.pixelToLatLon(px, py, rect.width, rect.height);
        this.polygon[this.draggingIdx] = {
          latitude: lat.toFixed(7),
          longitude: lon.toFixed(7)
        };
        this.renderVectorAndMarkers(rect.width, rect.height);
      };
      this.onMouseUp = () => {
        if (this.draggingIdx !== null) {
          this.draggingIdx = null;
          this.pushEvent("update_geofence_polygon", { polygon: this.polygon });
        }
      };
      document.addEventListener("mousemove", this.onMouseMove);
      document.addEventListener("mouseup", this.onMouseUp);
    },
    computeCenter() {
      const pts = [
        ...this.addresses.map((a) => ({ lat: parseFloat(a.latitude), lon: parseFloat(a.longitude) })),
        ...this.polygon.map((p) => ({ lat: parseFloat(p.latitude), lon: parseFloat(p.longitude) }))
      ].filter((p) => !isNaN(p.lat) && !isNaN(p.lon));
      if (pts.length === 0) {
        return { lat: 52.5200066, lon: 13.404954 };
      }
      const minLat = Math.min(...pts.map((p) => p.lat));
      const maxLat = Math.max(...pts.map((p) => p.lat));
      const minLon = Math.min(...pts.map((p) => p.lon));
      const maxLon = Math.max(...pts.map((p) => p.lon));
      return { lat: (minLat + maxLat) / 2, lon: (minLon + maxLon) / 2 };
    },
    latLonToTileXY(lat, lon, z) {
      const n = Math.pow(2, z);
      const x = (lon + 180) / 360 * n;
      const latRad = lat * Math.PI / 180;
      const y = (1 - Math.log(Math.tan(latRad) + 1 / Math.cos(latRad)) / Math.PI) / 2 * n;
      return { x, y };
    },
    tileXYToLatLon(x, y, z) {
      const n = Math.pow(2, z);
      const lon = x / n * 360 - 180;
      const latRad = Math.atan(Math.sinh(Math.PI * (1 - 2 * y / n)));
      const lat = latRad * 180 / Math.PI;
      return { lat, lon };
    },
    latLonToPixel(lat, lon, width, height) {
      const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom);
      const ptTile = this.latLonToTileXY(lat, lon, this.zoom);
      return {
        x: width / 2 + (ptTile.x - centerTile.x) * 256,
        y: height / 2 + (ptTile.y - centerTile.y) * 256
      };
    },
    pixelToLatLon(px, py, width, height) {
      const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom);
      const tileX = centerTile.x + (px - width / 2) / 256;
      const tileY = centerTile.y + (py - height / 2) / 256;
      return this.tileXYToLatLon(tileX, tileY, this.zoom);
    },
    renderMap() {
      const rect = this.canvasEl.getBoundingClientRect();
      const width = rect.width || 800;
      const height = rect.height || 384;
      this.center = this.computeCenter();
      this.renderTiles(width, height);
      this.renderVectorAndMarkers(width, height);
    },
    renderTiles(width, height) {
      this.tileLayer.innerHTML = "";
      const centerTile = this.latLonToTileXY(this.center.lat, this.center.lon, this.zoom);
      const startX = Math.floor(centerTile.x - width / 512) - 1;
      const endX = Math.ceil(centerTile.x + width / 512) + 1;
      const startY = Math.floor(centerTile.y - height / 512) - 1;
      const endY = Math.ceil(centerTile.y + height / 512) + 1;
      const subdomains = ["a", "b", "c"];
      for (let tx = startX; tx <= endX; tx++) {
        for (let ty = startY; ty <= endY; ty++) {
          const img = document.createElement("img");
          const s = subdomains[Math.abs(tx + ty) % subdomains.length];
          img.src = this.tileUrl.replace("{s}", s).replace("{z}", this.zoom).replace("{x}", tx).replace("{y}", ty);
          img.alt = "";
          img.style.position = "absolute";
          img.style.width = "256px";
          img.style.height = "256px";
          img.style.left = `${Math.round(width / 2 + (tx - centerTile.x) * 256)}px`;
          img.style.top = `${Math.round(height / 2 + (ty - centerTile.y) * 256)}px`;
          this.tileLayer.appendChild(img);
        }
      }
    },
    renderVectorAndMarkers(width, height) {
      this.svgOverlay.innerHTML = "";
      this.markerLayer.innerHTML = "";
      if (this.polygon.length >= 3) {
        const polyPts = this.polygon.map(
          (p) => this.latLonToPixel(parseFloat(p.latitude), parseFloat(p.longitude), width, height)
        );
        const polyEl = document.createElementNS("http://www.w3.org/2000/svg", "polygon");
        polyEl.setAttribute("points", polyPts.map((pt) => `${pt.x},${pt.y}`).join(" "));
        polyEl.setAttribute("fill", "rgba(37, 99, 235, 0.18)");
        polyEl.setAttribute("stroke", "#2563EB");
        polyEl.setAttribute("stroke-width", "2");
        this.svgOverlay.appendChild(polyEl);
        if (this.editable) {
          polyPts.forEach((pt, idx) => {
            const handle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
            handle.setAttribute("cx", pt.x);
            handle.setAttribute("cy", pt.y);
            handle.setAttribute("r", "6");
            handle.setAttribute("fill", "#FFFFFF");
            handle.setAttribute("stroke", "#2563EB");
            handle.setAttribute("stroke-width", "2");
            handle.style.cursor = "grab";
            handle.addEventListener("mousedown", (e) => {
              e.stopPropagation();
              this.draggingIdx = idx;
            });
            this.svgOverlay.appendChild(handle);
          });
        }
      }
      this.addresses.forEach((addr) => {
        const lat = parseFloat(addr.latitude);
        const lon = parseFloat(addr.longitude);
        if (isNaN(lat) || isNaN(lon)) return;
        const pt = this.latLonToPixel(lat, lon, width, height);
        const pin = document.createElement("div");
        pin.style.position = "absolute";
        pin.style.left = `${pt.x}px`;
        pin.style.top = `${pt.y}px`;
        pin.style.transform = "translate(-50%, -100%)";
        pin.style.background = addr.is_primary ? "#2563EB" : "#0F172A";
        pin.style.color = "#FFFFFF";
        pin.style.padding = "2px 6px";
        pin.style.borderRadius = "4px";
        pin.style.fontSize = "11px";
        pin.style.fontWeight = "600";
        pin.style.whiteSpace = "nowrap";
        pin.style.boxShadow = "0 1px 3px rgba(0,0,0,0.3)";
        pin.textContent = `${addr.street} ${addr.house_number}`;
        this.markerLayer.appendChild(pin);
      });
    }
  };
  var liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
    params: { _csrf_token: csrfToken },
    hooks: Hooks2
  });
  liveSocket.connect();
  window.liveSocket = liveSocket;
})();
/*!
 * Cropper.js v1.6.2
 * https://fengyuanchen.github.io/cropperjs
 *
 * Copyright 2015-present Chen Fengyuan
 * Released under the MIT license
 *
 * Date: 2024-04-21T07:43:05.335Z
 */
