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
exports.id = "pages/_app";
exports.ids = ["pages/_app"];
exports.modules = {

/***/ "./lib/UserContext.tsx":
/*!*****************************!*\
  !*** ./lib/UserContext.tsx ***!
  \*****************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"UserContextProvider\": () => (/* binding */ UserContextProvider),\n/* harmony export */   \"useUser\": () => (/* binding */ useUser)\n/* harmony export */ });\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react/jsx-dev-runtime */ \"react/jsx-dev-runtime\");\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ \"react\");\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);\n\n\nconst UserContext = /*#__PURE__*/ (0,react__WEBPACK_IMPORTED_MODULE_1__.createContext)({\n    user: null,\n    session: null\n});\nconst UserContextProvider = ({ supabaseClient , children  })=>{\n    const { 0: session1 , 1: setSession  } = (0,react__WEBPACK_IMPORTED_MODULE_1__.useState)(null);\n    const { 0: user , 1: setUser  } = (0,react__WEBPACK_IMPORTED_MODULE_1__.useState)(null);\n    (0,react__WEBPACK_IMPORTED_MODULE_1__.useEffect)(()=>{\n        const session2 = supabaseClient.auth.session();\n        setSession(session2);\n        var ref1;\n        setUser((ref1 = session2 === null || session2 === void 0 ? void 0 : session2.user) !== null && ref1 !== void 0 ? ref1 : null);\n        const { data: authListener  } = supabaseClient.auth.onAuthStateChange(async (event, session)=>{\n            setSession(session);\n            var ref;\n            setUser((ref = session === null || session === void 0 ? void 0 : session.user) !== null && ref !== void 0 ? ref : null);\n        });\n        return ()=>{\n            authListener === null || authListener === void 0 ? void 0 : authListener.unsubscribe();\n        };\n    }, []);\n    const value = {\n        session: session1,\n        user\n    };\n    return /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(UserContext.Provider, {\n        value: value,\n        children: children\n    }, void 0, false, {\n        fileName: \"/Users/villeheikkila/Developer/tasted/lib/UserContext.tsx\",\n        lineNumber: 42,\n        columnNumber: 10\n    }, undefined);\n};\nconst useUser = ()=>{\n    const context = (0,react__WEBPACK_IMPORTED_MODULE_1__.useContext)(UserContext);\n    if (context === undefined) {\n        throw new Error(`useUser must be used within a UserContextProvider.`);\n    }\n    return context;\n};\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiLi9saWIvVXNlckNvbnRleHQudHN4LmpzIiwibWFwcGluZ3MiOiI7Ozs7Ozs7OztBQUFBO0FBQzhFO0FBRTlFLE1BQU1LLFdBQVcsaUJBQUdGLG9EQUFhLENBRzlCO0lBQUVHLElBQUksRUFBRSxJQUFJO0lBQUVDLE9BQU8sRUFBRSxJQUFJO0NBQUUsQ0FBQztBQU8xQixNQUFNQyxtQkFBbUIsR0FBRyxDQUFDLEVBQ2xDQyxjQUFjLEdBQ2RDLFFBQVEsR0FDK0IsR0FBSztJQUM1QyxNQUFNLEVBakJSLEdBaUJTSCxRQUFPLEdBakJoQixHQWlCa0JJLFVBQVUsTUFBSVQsK0NBQVEsQ0FBaUIsSUFBSSxDQUFDO0lBQzVELE1BQU0sRUFsQlIsR0FrQlNJLElBQUksR0FsQmIsR0FrQmVNLE9BQU8sTUFBSVYsK0NBQVEsQ0FBYyxJQUFJLENBQUM7SUFFbkRELGdEQUFTLENBQUMsSUFBTTtRQUNkLE1BQU1NLFFBQU8sR0FBR0UsY0FBYyxDQUFDSSxJQUFJLENBQUNOLE9BQU8sRUFBRTtRQUM3Q0ksVUFBVSxDQUFDSixRQUFPLENBQUMsQ0FBQztZQUNaQSxJQUFhO1FBQXJCSyxPQUFPLENBQUNMLENBQUFBLElBQWEsR0FBYkEsUUFBTyxhQUFQQSxRQUFPLFdBQU0sR0FBYkEsS0FBQUEsQ0FBYSxHQUFiQSxRQUFPLENBQUVELElBQUksY0FBYkMsSUFBYSxjQUFiQSxJQUFhLEdBQUksSUFBSSxDQUFDLENBQUM7UUFDL0IsTUFBTSxFQUFFTyxJQUFJLEVBQUVDLFlBQVksR0FBRSxHQUFHTixjQUFjLENBQUNJLElBQUksQ0FBQ0csaUJBQWlCLENBQ2xFLE9BQU9DLEtBQUssRUFBRVYsT0FBTyxHQUFLO1lBQ3hCSSxVQUFVLENBQUNKLE9BQU8sQ0FBQyxDQUFDO2dCQUNaQSxHQUFhO1lBQXJCSyxPQUFPLENBQUNMLENBQUFBLEdBQWEsR0FBYkEsT0FBTyxhQUFQQSxPQUFPLFdBQU0sR0FBYkEsS0FBQUEsQ0FBYSxHQUFiQSxPQUFPLENBQUVELElBQUksY0FBYkMsR0FBYSxjQUFiQSxHQUFhLEdBQUksSUFBSSxDQUFDLENBQUM7U0FDaEMsQ0FDRjtRQUVELE9BQU8sSUFBTTtZQUNYUSxZQUFZLGFBQVpBLFlBQVksV0FBYSxHQUF6QkEsS0FBQUEsQ0FBeUIsR0FBekJBLFlBQVksQ0FBRUcsV0FBVyxFQUFFLENBQUM7U0FDN0IsQ0FBQztLQUNILEVBQUUsRUFBRSxDQUFDLENBQUM7SUFFUCxNQUFNQyxLQUFLLEdBQUc7UUFDWlosT0FBTyxFQUFQQSxRQUFPO1FBQ1BELElBQUk7S0FDTDtJQUVELHFCQUFPLDhEQUFDRCxXQUFXLENBQUNlLFFBQVE7UUFBQ0QsS0FBSyxFQUFFQSxLQUFLO2tCQUFHVCxRQUFROzs7OztpQkFBd0IsQ0FBQztDQUM5RSxDQUFDO0FBRUssTUFBTVcsT0FBTyxHQUFHLElBQU07SUFDM0IsTUFBTUMsT0FBTyxHQUFHbEIsaURBQVUsQ0FBQ0MsV0FBVyxDQUFDO0lBQ3ZDLElBQUlpQixPQUFPLEtBQUtDLFNBQVMsRUFBRTtRQUN6QixNQUFNLElBQUlDLEtBQUssQ0FBQyxDQUFDLGtEQUFrRCxDQUFDLENBQUMsQ0FBQztLQUN2RTtJQUNELE9BQU9GLE9BQU8sQ0FBQztDQUNoQixDQUFDIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vd2l0aC1zdXBhYmFzZS1hdXRoLy4vbGliL1VzZXJDb250ZXh0LnRzeD80Y2M3Il0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCB7IFNlc3Npb24sIFN1cGFiYXNlQ2xpZW50LCBVc2VyIH0gZnJvbSBcIkBzdXBhYmFzZS9zdXBhYmFzZS1qc1wiO1xuaW1wb3J0IFJlYWN0LCB7IHVzZUVmZmVjdCwgdXNlU3RhdGUsIGNyZWF0ZUNvbnRleHQsIHVzZUNvbnRleHQgfSBmcm9tIFwicmVhY3RcIjtcblxuY29uc3QgVXNlckNvbnRleHQgPSBjcmVhdGVDb250ZXh0PHtcbiAgdXNlcjogbnVsbCB8IFVzZXI7XG4gIHNlc3Npb246IG51bGwgfCBTZXNzaW9uO1xufT4oeyB1c2VyOiBudWxsLCBzZXNzaW9uOiBudWxsIH0pO1xuXG50eXBlIFdpdGhDaGlsZHJlbjxUID0ge30+ID0gVCAmIHsgY2hpbGRyZW4/OiBSZWFjdC5SZWFjdE5vZGUgfTtcblxuaW50ZXJmYWNlIFVzZXJDb250ZXh0UHJvdmlkZXJQcm9wcyB7XG4gIHN1cGFiYXNlQ2xpZW50OiBTdXBhYmFzZUNsaWVudDtcbn1cbmV4cG9ydCBjb25zdCBVc2VyQ29udGV4dFByb3ZpZGVyID0gKHtcbiAgc3VwYWJhc2VDbGllbnQsXG4gIGNoaWxkcmVuLFxufTogV2l0aENoaWxkcmVuPFVzZXJDb250ZXh0UHJvdmlkZXJQcm9wcz4pID0+IHtcbiAgY29uc3QgW3Nlc3Npb24sIHNldFNlc3Npb25dID0gdXNlU3RhdGU8U2Vzc2lvbiB8IG51bGw+KG51bGwpO1xuICBjb25zdCBbdXNlciwgc2V0VXNlcl0gPSB1c2VTdGF0ZTxVc2VyIHwgbnVsbD4obnVsbCk7XG5cbiAgdXNlRWZmZWN0KCgpID0+IHtcbiAgICBjb25zdCBzZXNzaW9uID0gc3VwYWJhc2VDbGllbnQuYXV0aC5zZXNzaW9uKCk7XG4gICAgc2V0U2Vzc2lvbihzZXNzaW9uKTtcbiAgICBzZXRVc2VyKHNlc3Npb24/LnVzZXIgPz8gbnVsbCk7XG4gICAgY29uc3QgeyBkYXRhOiBhdXRoTGlzdGVuZXIgfSA9IHN1cGFiYXNlQ2xpZW50LmF1dGgub25BdXRoU3RhdGVDaGFuZ2UoXG4gICAgICBhc3luYyAoZXZlbnQsIHNlc3Npb24pID0+IHtcbiAgICAgICAgc2V0U2Vzc2lvbihzZXNzaW9uKTtcbiAgICAgICAgc2V0VXNlcihzZXNzaW9uPy51c2VyID8/IG51bGwpO1xuICAgICAgfVxuICAgICk7XG5cbiAgICByZXR1cm4gKCkgPT4ge1xuICAgICAgYXV0aExpc3RlbmVyPy51bnN1YnNjcmliZSgpO1xuICAgIH07XG4gIH0sIFtdKTtcblxuICBjb25zdCB2YWx1ZSA9IHtcbiAgICBzZXNzaW9uLFxuICAgIHVzZXIsXG4gIH07XG5cbiAgcmV0dXJuIDxVc2VyQ29udGV4dC5Qcm92aWRlciB2YWx1ZT17dmFsdWV9PntjaGlsZHJlbn08L1VzZXJDb250ZXh0LlByb3ZpZGVyPjtcbn07XG5cbmV4cG9ydCBjb25zdCB1c2VVc2VyID0gKCkgPT4ge1xuICBjb25zdCBjb250ZXh0ID0gdXNlQ29udGV4dChVc2VyQ29udGV4dCk7XG4gIGlmIChjb250ZXh0ID09PSB1bmRlZmluZWQpIHtcbiAgICB0aHJvdyBuZXcgRXJyb3IoYHVzZVVzZXIgbXVzdCBiZSB1c2VkIHdpdGhpbiBhIFVzZXJDb250ZXh0UHJvdmlkZXIuYCk7XG4gIH1cbiAgcmV0dXJuIGNvbnRleHQ7XG59O1xuIl0sIm5hbWVzIjpbIlJlYWN0IiwidXNlRWZmZWN0IiwidXNlU3RhdGUiLCJjcmVhdGVDb250ZXh0IiwidXNlQ29udGV4dCIsIlVzZXJDb250ZXh0IiwidXNlciIsInNlc3Npb24iLCJVc2VyQ29udGV4dFByb3ZpZGVyIiwic3VwYWJhc2VDbGllbnQiLCJjaGlsZHJlbiIsInNldFNlc3Npb24iLCJzZXRVc2VyIiwiYXV0aCIsImRhdGEiLCJhdXRoTGlzdGVuZXIiLCJvbkF1dGhTdGF0ZUNoYW5nZSIsImV2ZW50IiwidW5zdWJzY3JpYmUiLCJ2YWx1ZSIsIlByb3ZpZGVyIiwidXNlVXNlciIsImNvbnRleHQiLCJ1bmRlZmluZWQiLCJFcnJvciJdLCJzb3VyY2VSb290IjoiIn0=\n//# sourceURL=webpack-internal:///./lib/UserContext.tsx\n");

/***/ }),

/***/ "./pages/_app.tsx":
/*!************************!*\
  !*** ./pages/_app.tsx ***!
  \************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (/* binding */ MyApp)\n/* harmony export */ });\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react/jsx-dev-runtime */ \"react/jsx-dev-runtime\");\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var _lib_UserContext__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../lib/UserContext */ \"./lib/UserContext.tsx\");\n/* harmony import */ var _utils_initSupabase__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../utils/initSupabase */ \"./utils/initSupabase.ts\");\n/* harmony import */ var _nextui_org_react__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @nextui-org/react */ \"@nextui-org/react\");\n/* harmony import */ var _nextui_org_react__WEBPACK_IMPORTED_MODULE_3___default = /*#__PURE__*/__webpack_require__.n(_nextui_org_react__WEBPACK_IMPORTED_MODULE_3__);\n\n\n\n\nconst darkTheme = (0,_nextui_org_react__WEBPACK_IMPORTED_MODULE_3__.createTheme)({\n    type: \"dark\",\n    theme: {\n        colors: {\n            background: \"rgb(24, 24, 24)\"\n        },\n        fonts: {\n            sans: '-apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\", \"Segoe UI Symbol\"'\n        }\n    }\n});\nfunction MyApp({ Component , pageProps  }) {\n    return /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(\"main\", {\n        children: /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(_lib_UserContext__WEBPACK_IMPORTED_MODULE_1__.UserContextProvider, {\n            supabaseClient: _utils_initSupabase__WEBPACK_IMPORTED_MODULE_2__.supabase,\n            children: /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(_nextui_org_react__WEBPACK_IMPORTED_MODULE_3__.NextUIProvider, {\n                theme: darkTheme,\n                children: /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(Component, {\n                    ...pageProps\n                }, void 0, false, {\n                    fileName: \"/Users/villeheikkila/Developer/tasted/pages/_app.tsx\",\n                    lineNumber: 23,\n                    columnNumber: 11\n                }, this)\n            }, void 0, false, {\n                fileName: \"/Users/villeheikkila/Developer/tasted/pages/_app.tsx\",\n                lineNumber: 22,\n                columnNumber: 9\n            }, this)\n        }, void 0, false, {\n            fileName: \"/Users/villeheikkila/Developer/tasted/pages/_app.tsx\",\n            lineNumber: 21,\n            columnNumber: 7\n        }, this)\n    }, void 0, false, {\n        fileName: \"/Users/villeheikkila/Developer/tasted/pages/_app.tsx\",\n        lineNumber: 20,\n        columnNumber: 5\n    }, this);\n};\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiLi9wYWdlcy9fYXBwLnRzeC5qcyIsIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7O0FBQUE7QUFBeUQ7QUFDUjtBQUNlO0FBR2hFLE1BQU1JLFNBQVMsR0FBR0YsOERBQVcsQ0FBQztJQUM1QkcsSUFBSSxFQUFFLE1BQU07SUFDWkMsS0FBSyxFQUFFO1FBQ0xDLE1BQU0sRUFBRTtZQUNOQyxVQUFVLEVBQUUsaUJBQWlCO1NBQzlCO1FBQ0RDLEtBQUssRUFBRTtZQUNMQyxJQUFJLEVBQUUsK0lBQStJO1NBQ3RKO0tBQ0Y7Q0FDRixDQUFDO0FBRWEsU0FBU0MsS0FBSyxDQUFDLEVBQUVDLFNBQVMsR0FBRUMsU0FBUyxHQUFZLEVBQUU7SUFDaEUscUJBQ0UsOERBQUNDLE1BQUk7a0JBQ0gsNEVBQUNkLGlFQUFtQjtZQUFDZSxjQUFjLEVBQUVkLHlEQUFRO3NCQUMzQyw0RUFBQ0UsNkRBQWM7Z0JBQUNHLEtBQUssRUFBRUYsU0FBUzswQkFDOUIsNEVBQUNRLFNBQVM7b0JBQUUsR0FBR0MsU0FBUzs7Ozs7d0JBQUk7Ozs7O29CQUNiOzs7OztnQkFDRzs7Ozs7WUFDakIsQ0FDUDtDQUNIIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vd2l0aC1zdXBhYmFzZS1hdXRoLy4vcGFnZXMvX2FwcC50c3g/MmZiZSJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBVc2VyQ29udGV4dFByb3ZpZGVyIH0gZnJvbSBcIi4uL2xpYi9Vc2VyQ29udGV4dFwiO1xuaW1wb3J0IHsgc3VwYWJhc2UgfSBmcm9tIFwiLi4vdXRpbHMvaW5pdFN1cGFiYXNlXCI7XG5pbXBvcnQgeyBjcmVhdGVUaGVtZSwgTmV4dFVJUHJvdmlkZXIgfSBmcm9tIFwiQG5leHR1aS1vcmcvcmVhY3RcIjtcbmltcG9ydCB7IEFwcFByb3BzIH0gZnJvbSBcIm5leHQvYXBwXCI7XG5cbmNvbnN0IGRhcmtUaGVtZSA9IGNyZWF0ZVRoZW1lKHtcbiAgdHlwZTogXCJkYXJrXCIsXG4gIHRoZW1lOiB7XG4gICAgY29sb3JzOiB7XG4gICAgICBiYWNrZ3JvdW5kOiBcInJnYigyNCwgMjQsIDI0KVwiLFxuICAgIH0sXG4gICAgZm9udHM6IHtcbiAgICAgIHNhbnM6ICctYXBwbGUtc3lzdGVtLCBCbGlua01hY1N5c3RlbUZvbnQsIFwiU2Vnb2UgVUlcIiwgUm9ib3RvLCBIZWx2ZXRpY2EsIEFyaWFsLCBzYW5zLXNlcmlmLCBcIkFwcGxlIENvbG9yIEVtb2ppXCIsIFwiU2Vnb2UgVUkgRW1vamlcIiwgXCJTZWdvZSBVSSBTeW1ib2xcIicsXG4gICAgfSxcbiAgfSxcbn0pO1xuXG5leHBvcnQgZGVmYXVsdCBmdW5jdGlvbiBNeUFwcCh7IENvbXBvbmVudCwgcGFnZVByb3BzIH06IEFwcFByb3BzKSB7XG4gIHJldHVybiAoXG4gICAgPG1haW4+XG4gICAgICA8VXNlckNvbnRleHRQcm92aWRlciBzdXBhYmFzZUNsaWVudD17c3VwYWJhc2V9PlxuICAgICAgICA8TmV4dFVJUHJvdmlkZXIgdGhlbWU9e2RhcmtUaGVtZX0+XG4gICAgICAgICAgPENvbXBvbmVudCB7Li4ucGFnZVByb3BzfSAvPlxuICAgICAgICA8L05leHRVSVByb3ZpZGVyPlxuICAgICAgPC9Vc2VyQ29udGV4dFByb3ZpZGVyPlxuICAgIDwvbWFpbj5cbiAgKTtcbn1cbiJdLCJuYW1lcyI6WyJVc2VyQ29udGV4dFByb3ZpZGVyIiwic3VwYWJhc2UiLCJjcmVhdGVUaGVtZSIsIk5leHRVSVByb3ZpZGVyIiwiZGFya1RoZW1lIiwidHlwZSIsInRoZW1lIiwiY29sb3JzIiwiYmFja2dyb3VuZCIsImZvbnRzIiwic2FucyIsIk15QXBwIiwiQ29tcG9uZW50IiwicGFnZVByb3BzIiwibWFpbiIsInN1cGFiYXNlQ2xpZW50Il0sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///./pages/_app.tsx\n");

/***/ }),

/***/ "./utils/initSupabase.ts":
/*!*******************************!*\
  !*** ./utils/initSupabase.ts ***!
  \*******************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"supabase\": () => (/* binding */ supabase)\n/* harmony export */ });\n/* harmony import */ var _supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @supabase/supabase-js */ \"@supabase/supabase-js\");\n/* harmony import */ var _supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__);\n\nconst supabase = (0,_supabase_supabase_js__WEBPACK_IMPORTED_MODULE_0__.createClient)(String(\"https://iykihowuxxkqxobggkuk.supabase.co\"), String(\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml5a2lob3d1eHhrcXhvYmdna3VrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NDg5ODc2NjUsImV4cCI6MTk2NDU2MzY2NX0.FD9Lf4Km2IwklnCuWBTCKB18mfZjPj8FA4YtEtHpe-o\"));\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiLi91dGlscy9pbml0U3VwYWJhc2UudHMuanMiLCJtYXBwaW5ncyI6Ijs7Ozs7O0FBQW9EO0FBRTdDLE1BQU1DLFFBQVEsR0FBR0QsbUVBQVksQ0FDbENFLE1BQU0sQ0FBQ0MsMENBQW9DLENBQUMsRUFDNUNELE1BQU0sQ0FBQ0Msa05BQXlDLENBQUMsQ0FDbEQiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly93aXRoLXN1cGFiYXNlLWF1dGgvLi91dGlscy9pbml0U3VwYWJhc2UudHM/YTc2YiJdLCJzb3VyY2VzQ29udGVudCI6WyJpbXBvcnQgeyBjcmVhdGVDbGllbnQgfSBmcm9tICdAc3VwYWJhc2Uvc3VwYWJhc2UtanMnXG5cbmV4cG9ydCBjb25zdCBzdXBhYmFzZSA9IGNyZWF0ZUNsaWVudChcbiAgU3RyaW5nKHByb2Nlc3MuZW52Lk5FWFRfUFVCTElDX1NVUEFCQVNFX1VSTCksXG4gIFN0cmluZyhwcm9jZXNzLmVudi5ORVhUX1BVQkxJQ19TVVBBQkFTRV9BTk9OX0tFWSlcbilcbiJdLCJuYW1lcyI6WyJjcmVhdGVDbGllbnQiLCJzdXBhYmFzZSIsIlN0cmluZyIsInByb2Nlc3MiLCJlbnYiLCJORVhUX1BVQkxJQ19TVVBBQkFTRV9VUkwiLCJORVhUX1BVQkxJQ19TVVBBQkFTRV9BTk9OX0tFWSJdLCJzb3VyY2VSb290IjoiIn0=\n//# sourceURL=webpack-internal:///./utils/initSupabase.ts\n");

/***/ }),

/***/ "@nextui-org/react":
/*!************************************!*\
  !*** external "@nextui-org/react" ***!
  \************************************/
/***/ ((module) => {

module.exports = require("@nextui-org/react");

/***/ }),

/***/ "@supabase/supabase-js":
/*!****************************************!*\
  !*** external "@supabase/supabase-js" ***!
  \****************************************/
/***/ ((module) => {

module.exports = require("@supabase/supabase-js");

/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "react" ***!
  \************************/
/***/ ((module) => {

module.exports = require("react");

/***/ }),

/***/ "react/jsx-dev-runtime":
/*!****************************************!*\
  !*** external "react/jsx-dev-runtime" ***!
  \****************************************/
/***/ ((module) => {

module.exports = require("react/jsx-dev-runtime");

/***/ })

};
;

// load runtime
var __webpack_require__ = require("../webpack-runtime.js");
__webpack_require__.C(exports);
var __webpack_exec__ = (moduleId) => (__webpack_require__(__webpack_require__.s = moduleId))
var __webpack_exports__ = (__webpack_exec__("./pages/_app.tsx"));
module.exports = __webpack_exports__;

})();