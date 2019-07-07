import * as React from "react";
import { Link } from "react-router-dom";

export const Navbar = () => {
    return (
        <div>
            <nav>
                <ul>
                    <li>
                        <Link to="/">Index</Link>
                    </li>
                    <li>
                        <Link to="/addproduct/">Add Product</Link>
                    </li>
                    <li>
                        <Link to="/users/">Add User</Link>
                    </li>
                    <li>
                        <Link to="/products/">Add Products</Link>
                    </li>
                </ul>
            </nav>
        </div>
    )
}