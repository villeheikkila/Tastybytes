import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Card from "@material-ui/core/Card";
import CardContent from "@material-ui/core/CardContent";
import Avatar from "@material-ui/core/Avatar";
import IconButton from "@material-ui/core/IconButton";
import Typography from "@material-ui/core/Typography";
import DoneOutline from "@material-ui/icons/DoneOutline";
import lipton from "../../images/lipton.jpg";
import { Link } from "react-router-dom";

import { IProductCard } from "../../types";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 700,
    margin: `${theme.spacing(1)}px auto`,
    display: "flex"
  },
  picture: {
    margin: 10,
    width: 100,
    height: 100
  },
  checkin: {}
}));

export const ProductCard: React.FC<IProductCard> = ({ product, show }) => {
  const classes = useStyles();
  const { id, name, producer, category, subCategory } = product;
  return (
    <Card className={classes.card}>
      <Avatar alt="Image" src={lipton} className={classes.picture} />
      <CardContent>
        <Typography variant="h5" color="textSecondary" component="p">
          {name}
        </Typography>
        <Typography variant="h6" color="textSecondary" component="p">
          {producer}
        </Typography>
        <Typography variant="h6" color="textSecondary" component="p">
          {category} {subCategory}
        </Typography>
      </CardContent>

      {show && (
        <IconButton
          aria-label="CheckIn"
          className={classes.checkin}
          component={Link}
          to={`/product/${id}`}
        >
          <DoneOutline color="primary" fontSize="large" />
        </IconButton>
      )}
    </Card>
  );
};
