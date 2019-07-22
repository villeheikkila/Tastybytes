import React from "react";
import { Link as RouterLink } from "react-router-dom";
import useReactRouter from "use-react-router";
import { IProductCard } from "../../types";
import lipton from "../../images/lipton.jpg";

import {
  Card,
  Link,
  Avatar,
  Typography,
  CardContent,
  CardActionArea,
  makeStyles
} from "@material-ui/core";

const useStyles = makeStyles(theme => ({
  card: {
    maxWidth: 700,
    margin: `${theme.spacing(1)}px auto`,
    display: "flex"
  },
  actionArea: {
    display: "flex",
    flexDirection: "row",
    justifyContent: "left"
  },
  picture: {
    margin: 10,
    width: 100,
    height: 100
  },
  details: {
    display: "flex",
    flexDirection: "column",
    paddingLeft: theme.spacing(1),
    paddingBottom: theme.spacing(1)
  }
}));

export const ProductCard: React.FC<IProductCard> = ({ product }) => {
  const classes = useStyles();
  const { history } = useReactRouter();
  const { id, name, producer, category, subCategory } = product;

  return (
    <Card className={classes.card}>
      <CardActionArea
        onClick={() => history.push(`/product/${id}`)}
        className={classes.actionArea}
      >
        <Avatar alt="Image" src={lipton} className={classes.picture} />
        <div className={classes.details}>
          <CardContent>
            <Typography variant="h5" color="textSecondary" component="p">
              <Link component={RouterLink} to={`/product/${id}`}>
                {name}
              </Link>
            </Typography>

            <Typography variant="h6" color="textPrimary" component="p">
              {producer}
            </Typography>

            {category[0] && (
              <Typography variant="body1" color="textPrimary" component="p">
                Category:
              </Typography>
            )}

            {category.map((e: any) => (
              <Typography
                key={e.name}
                variant="body1"
                color="textPrimary"
                component="p"
              >
                {e.name}
              </Typography>
            ))}

            {subCategory[0] && (
              <Typography variant="body1" color="textPrimary" component="p">
                Style:
              </Typography>
            )}

            {subCategory.map((e: any) => (
              <Typography
                key={e.name}
                variant="body1"
                color="textPrimary"
                component="p"
              >
                {e.name}
              </Typography>
            ))}
          </CardContent>
        </div>
      </CardActionArea>
    </Card>
  );
};
