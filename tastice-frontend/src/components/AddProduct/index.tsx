import React, { useState } from "react";
import { ADD_PRODUCT } from "../../queries";
import { useMutation } from "@apollo/react-hooks";
import { notificationHandler, errorHandler } from "../../utils";
import { makeStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import { ValidatorForm, TextValidator } from "react-material-ui-form-validator";
import Button from '@material-ui/core/Button';
import ReactSelectMaterialUi from "react-select-material-ui";

const useStyles = makeStyles(theme => ({
  root: {
    padding: theme.spacing(3, 2),
  },
  button: {
    margin: theme.spacing(1),
  },
}));

const options: string[] = ["Pepsi Co", "Coca Cola Company", "Olvi", "Europe"];


export const AddProduct = () => {
  const classes = useStyles();
  const [name, setName] = useState("");
  const [producer, setProducer] = useState("");
  const [type, setType] = useState("");
  const [addProduct] = useMutation(ADD_PRODUCT, {
    onError: errorHandler
  });

  const handleChange = (value: any) => {
    console.log(value);
  }

  const handleAddProduct = async (
    event: any) => {
    event.preventDefault();

    const result = await addProduct({
      variables: { name, producer, type }
    });

    if (result) {
      notificationHandler({
        message: `Product ${result.data.addProduct.name} succesfully added`,
        variant: "success"
      });
    }

    setName("");
    setProducer("");
    setType("");
  };

  const handleNameChange = (event: any) => setName(event.target.value)

  const handleProducerChange = (event: any) => setProducer(event.target.value);

  const handleTypeChange = (event: any) => setType(event.target.value)

  return (
    <div>
      <Paper className={classes.root}>
        <ValidatorForm
          onSubmit={handleAddProduct}
          onError={(errors: any) => console.log(errors)}
        >
          <TextValidator
            variant="outlined"
            required
            fullWidth
            id="Name"
            label="Name"
            name="Name"
            validators={['required', 'minStringLength: 3', 'maxStringLength: 12']}
            errorMessages={['This field is required', 'The name is too short', 'The name is too long']}
            value={name}
            onChange={handleNameChange}
          />

          <TextValidator
            variant="outlined"
            required
            fullWidth
            id="Producer"
            label="Producer"
            name="Producer"
            validators={['required', 'minStringLength: 3', 'maxStringLength: 12']}
            errorMessages={['This field is required', 'The name is too short', 'The name is too long']}
            value={producer}
            onChange={handleProducerChange}
          />

          <TextValidator
            variant="outlined"
            required
            fullWidth
            id="Type"
            label="Type"
            name="Type"
            validators={['required', 'minStringLength: 3', 'maxStringLength: 12']}
            errorMessages={['This field is required', 'The name is too short', 'The name is too long']}
            value={type}
            onChange={handleTypeChange}
          />

          <ReactSelectMaterialUi style={{ width: 100 }} value="Europe" options={options} onChange={handleChange} />

          <Button type="submit" variant="contained" color="secondary" className={classes.button}>
            Add Product!
          </Button>
        </ValidatorForm>
      </Paper>
    </div>
  );
};
