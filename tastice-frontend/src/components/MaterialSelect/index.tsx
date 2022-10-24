/* eslint import/named: 0 import/namespace: 0 */

import {
    Chip,
    createStyles,
    makeStyles,
    MenuItem,
    Paper,
    TextField,
    Theme,
    Typography,
    useTheme,
} from '@material-ui/core';
import { emphasize } from '@material-ui/core/styles';
import { BaseTextFieldProps } from '@material-ui/core/TextField';
import CancelIcon from '@material-ui/icons/Cancel';
import clsx from 'clsx';
import React, { CSSProperties, HTMLAttributes } from 'react';
import Select from 'react-select';
import CreatableSelect from 'react-select/creatable';
import { ValueContainerProps } from 'react-select/src/components/containers';
import { ControlProps } from 'react-select/src/components/Control';
import { MenuProps, NoticeProps } from 'react-select/src/components/Menu';
import { MultiValueProps } from 'react-select/src/components/MultiValue';
import { OptionProps } from 'react-select/src/components/Option';
import { PlaceholderProps } from 'react-select/src/components/Placeholder';
import { SingleValueProps } from 'react-select/src/components/SingleValue';

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

interface OptionType {
    label: string;
    value: string;
}

const NoOptionsMessage = ({ selectProps, innerProps, children }: NoticeProps<OptionType>): JSX.Element => {
    return (
        <Typography color="textSecondary" className={selectProps.classes.noOptionsMessage} {...innerProps}>
            {children}
        </Typography>
    );
};

type InputComponentProps = Pick<BaseTextFieldProps, 'inputRef'> & HTMLAttributes<HTMLDivElement>;

const inputComponent = ({ inputRef, ...props }: InputComponentProps): JSX.Element => {
    return <div ref={inputRef} {...props} />;
};

const Control = ({
    children,
    innerProps,
    innerRef,
    selectProps: { classes, TextFieldProps },
}: ControlProps<OptionType>): JSX.Element => {
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
};

const Option = ({ innerRef, isFocused, isSelected, innerProps, children }: OptionProps<OptionType>): JSX.Element => {
    return (
        <MenuItem
            ref={innerRef}
            selected={isFocused}
            component="div"
            style={{
                fontWeight: isSelected ? 500 : 400,
            }}
            {...innerProps}
        >
            {children}
        </MenuItem>
    );
};

type MuiPlaceholderProps = Omit<PlaceholderProps<OptionType>, 'innerProps'> &
    Partial<Pick<PlaceholderProps<OptionType>, 'innerProps'>>;

const Placeholder = ({ selectProps, innerProps, children }: MuiPlaceholderProps): JSX.Element => {
    return (
        <Typography color="textSecondary" className={selectProps.classes.placeholder} {...innerProps}>
            {children}
        </Typography>
    );
};

const SingleValue = ({ selectProps, innerProps, children }: SingleValueProps<OptionType>): JSX.Element => {
    return (
        <Typography className={selectProps.classes.singleValue} {...innerProps}>
            {children}
        </Typography>
    );
};

const ValueContainer = ({ selectProps, children }: ValueContainerProps<OptionType>): JSX.Element => {
    return <div className={selectProps.classes.valueContainer}>{children}</div>;
};

const MultiValue = ({ selectProps, children, removeProps, isFocused }: MultiValueProps<OptionType>): JSX.Element => {
    return (
        <Chip
            tabIndex={-1}
            label={children}
            className={clsx(selectProps.classes.chip, {
                [selectProps.classes.chipFocused]: isFocused,
            })}
            onDelete={removeProps.onClick}
            deleteIcon={<CancelIcon {...removeProps} />}
        />
    );
};

const Menu = ({ selectProps, innerProps, children }: MenuProps<OptionType>): JSX.Element => {
    return (
        <Paper square className={selectProps.classes.paper} {...innerProps}>
            {children}
        </Paper>
    );
};

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

interface Input {
    font: string;
}
interface SelectStyles extends CSSProperties {
    color: string;
    '& input': Input;
}

interface MaterialSelectProps {
    placeholder: string;
    label: string;
    isCreatable: boolean;
    isMulti: boolean;
    suggestions: [Suggestions];
    onChange: any;
    value: Suggestions;
}

export const MaterialSelect = ({
    placeholder,
    label,
    isCreatable,
    suggestions,
    value,
    isMulti,
    onChange,
}: MaterialSelectProps): JSX.Element => {
    const classes = useStyles({});
    const theme = useTheme();

    const selectStyles = {
        input: (base: CSSProperties): SelectStyles => ({
            ...base,
            color: theme.palette.text.primary,
            '& input': {
                font: 'inherit',
            },
        }),
    };

    return (
        <div className={classes.root}>
            {isCreatable ? (
                <CreatableSelect
                    classes={classes}
                    styles={selectStyles}
                    inputId="react-select-multiple"
                    TextFieldProps={{
                        label,
                        InputLabelProps: {
                            htmlFor: 'react-select-multiple',
                            shrink: true,
                        },
                    }}
                    placeholder={placeholder}
                    options={suggestions}
                    components={components}
                    value={value}
                    onChange={onChange}
                    isMulti={isMulti}
                />
            ) : (
                <Select
                    classes={classes}
                    styles={selectStyles}
                    inputId="react-select-multiple"
                    TextFieldProps={{
                        label,
                        InputLabelProps: {
                            htmlFor: 'react-select-multiple',
                            shrink: true,
                        },
                    }}
                    placeholder={placeholder}
                    options={suggestions}
                    components={components}
                    value={value}
                    onChange={onChange}
                    isMulti={isMulti}
                />
            )}
        </div>
    );
};
