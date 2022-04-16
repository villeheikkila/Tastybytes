"use strict";
/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
(() => {
var exports = {};
exports.id = "pages/api/getUser";
exports.ids = ["pages/api/getUser"];
exports.modules = {

/***/ "@supabase/supabase-js":
/*!****************************************!*\
  !*** external "@supabase/supabase-js" ***!
  \****************************************/
/***/ ((module) => {

module.exports = require("@supabase/supabase-js");

/***/ }),

/***/ "(api)/./pages/api/getUser.ts":
/*!******************************!*\
  !*** ./pages/api/getUser.ts ***!
  \******************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (__WEBPACK_DEFAULT_EXPORT__)\n/* harmony export */ });\n/* harmony import */ var _utils_initSupabase__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../utils/initSupabase */ \"(api)/./utils/initSupabase.ts\");\n\n/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (async (req, res)=>{\n    const token = req.headers.token;\n    const { data: user , error  } = await _utils_initSupabase__WEBPACK_IMPORTED_MODULE_0__.supabase.auth.api.getUser(String(token));\n    if (error) return res.status(401).json({\n        error: error.message\n    });\n    return res.status(200).json(user);\n});\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi9wYWdlcy9hcGkvZ2V0VXNlci50cy5qcyIsIm1hcHBpbmdzIjoiOzs7OztBQUNtRDtBQUVuRCxpRUFBZSxPQUFPQyxHQUFtQixFQUFFQyxHQUFvQixHQUFLO0lBQ2xFLE1BQU1DLEtBQUssR0FBR0YsR0FBRyxDQUFDRyxPQUFPLENBQUNELEtBQUs7SUFDL0IsTUFBTSxFQUFFRSxJQUFJLEVBQUVDLElBQUksR0FBRUMsS0FBSyxHQUFFLEdBQUcsTUFBTVAsMEVBQXlCLENBQUNXLE1BQU0sQ0FBQ1IsS0FBSyxDQUFDLENBQUM7SUFDNUUsSUFBSUksS0FBSyxFQUFFLE9BQU9MLEdBQUcsQ0FBQ1UsTUFBTSxDQUFDLEdBQUcsQ0FBQyxDQUFDQyxJQUFJLENBQUM7UUFBRU4sS0FBSyxFQUFFQSxLQUFLLENBQUNPLE9BQU87S0FBRSxDQUFDO0lBQ2hFLE9BQU9aLEdBQUcsQ0FBQ1UsTUFBTSxDQUFDLEdBQUcsQ0FBQyxDQUFDQyxJQUFJLENBQUNQLElBQUksQ0FBQztDQUNsQyIsInNvdXJjZXMiOlsid2VicGFjazovL3dpdGgtc3VwYWJhc2UtYXV0aC8uL3BhZ2VzL2FwaS9nZXRVc2VyLnRzPzAxMTEiXSwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHsgTmV4dEFwaVJlcXVlc3QsIE5leHRBcGlSZXNwb25zZSB9IGZyb20gJ25leHQnXG5pbXBvcnQgeyBzdXBhYmFzZSB9IGZyb20gJy4uLy4uL3V0aWxzL2luaXRTdXBhYmFzZSdcblxuZXhwb3J0IGRlZmF1bHQgYXN5bmMgKHJlcTogTmV4dEFwaVJlcXVlc3QsIHJlczogTmV4dEFwaVJlc3BvbnNlKSA9PiB7XG4gIGNvbnN0IHRva2VuID0gcmVxLmhlYWRlcnMudG9rZW5cbiAgY29uc3QgeyBkYXRhOiB1c2VyLCBlcnJvciB9ID0gYXdhaXQgc3VwYWJhc2UuYXV0aC5hcGkuZ2V0VXNlcihTdHJpbmcodG9rZW4pKVxuICBpZiAoZXJyb3IpIHJldHVybiByZXMuc3RhdHVzKDQwMSkuanNvbih7IGVycm9yOiBlcnJvci5tZXNzYWdlIH0pXG4gIHJldHVybiByZXMuc3RhdHVzKDIwMCkuanNvbih1c2VyKVxufVxuXG4iXSwibmFtZXMiOlsic3VwYWJhc2UiLCJyZXEiLCJyZXMiLCJ0b2tlbiIsImhlYWRlcnMiLCJkYXRhIiwidXNlciIsImVycm9yIiwiYXV0aCIsImFwaSIsImdldFVzZXIiLCJTdHJpbmciLCJzdGF0dXMiLCJqc29uIiwibWVzc2FnZSJdLCJzb3VyY2VSb290IjoiIn0=\n//# sourceURL=webpack-internal:///(api)/./pages/api/getUser.ts\n");

/***/ }),

/***/ "(api)/./utils/initSupabase.ts":
/*!*******************************!*\
  !*** ./utils/initSupabase.ts ***!
  \*******************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"supabase\": () => (/* binding */ supabase)\n/* harmony export */ });\n/* harmony import */ var _supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @supabase/supabase-js */ \"@supabase/supabase-js\");\n/* harmony import */ var _supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__);\n\nconst supabase = (0,_supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__.createClient)(String(\"https://iykihowuxxkqxobggkuk.supabase.co\"), String(\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5a2lob3d1eHhrcXhvYmdna3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDg5ODc2NjUsImV4cCI6MTk2NDU2MzY2NX0.FD9Lf4Km2IwklnCuWBTCKB18mfZjPj8FA4YtEtHpe-o\"));\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKGFwaSkvLi91dGlscy9pbml0U3VwYWJhc2UudHMuanMiLCJtYXBwaW5ncyI6Ijs7Ozs7O0FBQW9EO0FBRTdDLE1BQU1DLFFBQVEsR0FBR0QsbUVBQVksQ0FDbENFLE1BQU0sQ0FBQ0MsMENBQW9DLENBQUMsRUFDNUNELE1BQU0sQ0FBQ0Msa05BQXlDLENBQUMsQ0FDbEQiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly93aXRoLXN1cGFiYXNlLWF1dGgvLi91dGlscy9pbml0U3VwYWJhc2UudHM/YTc2YiJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBjcmVhdGVDbGllbnQgfSBmcm9tICdAc3VwYWJhc2Uvc3VwYWJhc2UtanMnXG5cbmV4cG9ydCBjb25zdCBzdXBhYmFzZSA9IGNyZWF0ZUNsaWVudChcbiAgU3RyaW5nKHByb2Nlc3MuZW52Lk5FWFRfUFVCTElDX1NVUEFCQVNFX1VSTCksXG4gIFN0cmluZyhwcm9jZXNzLmVudi5ORVhUX1BVQkxJQ19TVVBBQkFTRV9BTk9OX0tFWSlcbilcbiJdLCJuYW1lcyI6WyJjcmVhdGVDbGllbnQiLCJzdXBhYmFzZSIsIlN0cmluZyIsInByb2Nlc3MiLCJlbnYiLCJORVhUX1BVQkxJQ19TVVBBQkFTRV9VUkwiLCJORVhUX1BVQkxJQ19TVVBBQkFTRV9BTk9OX0tFWSJdLCJzb3VyY2VSb290IjoiIn0=\n//# sourceURL=webpack-internal:///(api)/./utils/initSupabase.ts\n");

/***/ })

};
;

// load runtime
var __webpack_require__ = require("../../webpack-api-runtime.js");
__webpack_require__.C(exports);
var __webpack_exec__ = (moduleId) => (__webpack_require__(__webpack_require__.s = moduleId))
var __webpack_exports__ = (__webpack_exec__("(api)/./pages/api/getUser.ts"));
module.exports = __webpack_exports__;

})();