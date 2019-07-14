import React, { CSSProperties, HTMLAttributes, useState } from 'react';
import clsx from 'clsx';
import CreatableSelect from 'react-select/creatable';
import Select from 'react-select';
import { createStyles, emphasize, makeStyles, useTheme, Theme } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';
import TextField, { BaseTextFieldProps } from '@material-ui/core/TextField';
import Paper from '@material-ui/core/Paper';
import Chip from '@material-ui/core/Chip';
import MenuItem from '@material-ui/core/MenuItem';
import CancelIcon from '@material-ui/icons/Cancel';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        root: {
            flexGrow: 1,
            height: 80,
        },
        input: {
            display: 'flex',
            padding: 0,
            height: 'auto',
        },
        valueContainer: {
            display: 'flex',
            flexWrap: 'wrap',
            flex: 1,
            alignItems: 'center',
            overflow: 'hidden',
        },
        chip: {
            margin: theme.spacing(0.5, 0.25),
        },
        chipFocused: {
            backgroundColor: emphasize(
                theme.palette.type === 'light' ? theme.palette.grey[300] : theme.palette.grey[700],
                0.08,
            ),
        },
        noOptionsMessage: {
            padding: theme.spacing(1, 2),
        },
        singleValue: {
            fontSize: 16,
        },
        placeholder: {
            position: 'absolute',
            left: 2,
            bottom: 6,
            fontSize: 16,
        },
        paper: {
            position: 'absolute',
            zIndex: 1,
            marginTop: theme.spacing(1),
            left: 0,
            right: 0,
        },
        divider: {
            height: theme.spacing(2),
        },
    }),
);

const NoOptionsMessage = (props: any) => {
    return (
        <Typography
            color="textSecondary"
            className={props.selectProps.classes.noOptionsMessage}
            {...props.innerProps}
        >
            {props.children}
        </Typography>
    );
}

type InputComponentProps = Pick<BaseTextFieldProps, 'inputRef'> & HTMLAttributes<HTMLDivElement>;

const inputComponent = ({ inputRef, ...props }: InputComponentProps) => {
    return <div ref={inputRef} {...props} />;
}

const Control = (props: any) => {
    const {
        children,
        innerProps,
        innerRef,
        selectProps: { classes, TextFieldProps },
    } = props;

    return (
        <TextField
            fullWidth
            InputProps={{
                inputComponent,
                inputProps: {
                    className: classes.input,
                    ref: innerRef,
                    children,
                    ...innerProps,
                },
            }}
            {...TextFieldProps}
        />
    );
}

const Option = (props: any) => {
    return (
        <MenuItem
            ref={props.innerRef}
            selected={props.isFocused}
            component="div"
            style={{
                fontWeight: props.isSelected ? 500 : 400,
            }}
            {...props.innerProps}
        >
            {props.children}
        </MenuItem>
    );
}

const Placeholder = (props: any) => {
    return (
        <Typography
            color="textSecondary"
            className={props.selectProps.classes.placeholder}
            {...props.innerProps}
        >
            {props.children}
        </Typography>
    );
}


const SingleValue = (props: any) => {
    return (
        <Typography className={props.selectProps.classes.singleValue} {...props.innerProps}>
            {props.children}
        </Typography>
    );
}

const ValueContainer = (props: any) => {
    return <div className={props.selectProps.classes.valueContainer}>{props.children}</div>;
}


const MultiValue = (props: any) => {
    return (
        <Chip
            tabIndex={-1}
            label={props.children}
            className={clsx(props.selectProps.classes.chip, {
                [props.selectProps.classes.chipFocused]: props.isFocused,
            })}
            onDelete={props.removeProps.onClick}
            deleteIcon={<CancelIcon {...props.removeProps} />}
        />
    );
}


const Menu = (props: any) => {
    return (
        <Paper square className={props.selectProps.classes.paper} {...props.innerProps}>
            {props.children}
        </Paper>
    );
}

const components = {
    Control,
    Menu,
    MultiValue,
    NoOptionsMessage,
    Option,
    Placeholder,
    SingleValue,
    ValueContainer,
};

export const MaterialSelect = (props: any) => {
    const classes = useStyles();
    const theme = useTheme();

    const selectStyles = {
        input: (base: CSSProperties) => ({
            ...base,
            color: theme.palette.text.primary,
            '& input': {
                font: 'inherit',
            },
        }),
    };

    return (
        <div className={classes.root}>
            {props.isCreatable ? (
                <CreatableSelect
                    classes={classes}
                    styles={selectStyles}
                    inputId="react-select-multiple"
                    TextFieldProps={{
                        label: props.label,
                        InputLabelProps: {
                            htmlFor: 'react-select-multiple',
                            shrink: true,
                        },
                    }}
                    placeholder={props.placeholder}
                    options={props.suggestions}
                    components={components}
                    value={props.value}
                    onChange={props.onChange}
                    isMulti={props.isMulti}
                />
            ) : (
                    <Select
                        classes={classes}
                        styles={selectStyles}
                        inputId="react-select-multiple"
                        TextFieldProps={{
                            label: props.label,
                            InputLabelProps: {
                                htmlFor: 'react-select-multiple',
                                shrink: true,
                            },
                        }}
                        placeholder={props.placeholder}
                        options={props.suggestions}
                        components={components}
                        value={props.value}
                        onChange={props.onChange}
                        isMulti={props.isMulti}
                    />
                )}
        </div>

    );

}
