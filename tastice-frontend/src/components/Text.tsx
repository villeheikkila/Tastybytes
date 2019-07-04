import * as React from "react";

export interface TextProps { string: string; }

const Text = (props: TextProps) => {
    return (
        <div>
            <h1>Welcome to {props.string}!</h1>
        </div>
    )
}

export default Text