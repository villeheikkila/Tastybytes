import * as React from "react";
import { Link } from "react-router-dom";
import { INavbar } from '../../types'

export const Navbar: React.FC<INavbar> = ({ logout }) => {
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
                        <Link to="/users/">Users</Link>
                    </li>
                    <li>
                        <Link to="/products/">Products</Link>
                    </li>
                    <button onClick={logout}>Log out</button>
                </ul>
            </nav>
        </div>
    )
}